import XCTest
@testable import MarketPulse
import NetworkLayer

@MainActor
final class MarketPulseViewModelTests: XCTestCase {

    // MARK: - Fixtures

    /// 5 vagas com sobreposição proposital em categorias, skills e empresas.
    private func makeJobs() -> [RemotiveJobDTO] {
        [
            .makeStub(
                id: 1,
                company: "GitHub",
                category: "Software Development",
                tags: ["swift", "react", "aws"],
                daysAgo: 0
            ),
            .makeStub(
                id: 2,
                company: "GitHub",
                category: "Software Development",
                tags: ["python", "react"],
                daysAgo: 1
            ),
            .makeStub(
                id: 3,
                company: "Shopify",
                category: "Software Development",
                tags: ["ruby", "react"],
                daysAgo: 2
            ),
            .makeStub(
                id: 4,
                company: "Doist",
                category: "Design",
                tags: ["figma"],
                daysAgo: 3
            ),
            .makeStub(
                id: 5,
                company: "Zapier",
                category: "Customer Support",
                tags: ["zendesk"],
                daysAgo: 4
            )
        ]
    }

    private func makeVM(stub: MockMarketPulseService.Stub) -> (MarketPulseViewModel, MockMarketPulseService) {
        let mock = MockMarketPulseService(stub: stub)
        let vm = MarketPulseViewModel(service: mock)
        return (vm, mock)
    }

    // MARK: - Tests: ViewModel

    func test_load_withSuccess_setsLoadedStateWithAggregation() async {
        let (vm, mock) = makeVM(stub: .success(makeJobs()))

        await vm.load()

        guard case .loaded(let data) = vm.state else {
            XCTFail("Expected .loaded, got \(vm.state)")
            return
        }
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(data.totalJobs, 5)
        XCTAssertEqual(data.topCategories.count, 3)
        XCTAssertEqual(data.topCategories.first?.name, "Software Development")
        XCTAssertEqual(data.topCategories.first?.count, 3)
        XCTAssertTrue(data.topSkills.contains(where: { $0.name == "react" && $0.count == 3 }))
        XCTAssertEqual(data.topCompanies.first?.name, "Github") // agrupado por lowercase
        XCTAssertEqual(data.topCompanies.first?.count, 2)
    }

    func test_load_withNetworkError_setsErrorState() async {
        let (vm, _) = makeVM(stub: .failure(NetworkError.offline))

        await vm.load()

        guard case .error(let message) = vm.state else {
            XCTFail("Expected .error, got \(vm.state)")
            return
        }
        XCTAssertFalse(message.isEmpty)
    }

    func test_load_withEmptyArray_setsLoadedStateWithEmptyAggregations() async {
        let (vm, _) = makeVM(stub: .success([]))

        await vm.load()

        guard case .loaded(let data) = vm.state else {
            XCTFail("Expected .loaded, got \(vm.state)")
            return
        }
        XCTAssertEqual(data.totalJobs, 0)
        XCTAssertTrue(data.topCategories.isEmpty)
        XCTAssertTrue(data.topSkills.isEmpty)
        XCTAssertTrue(data.topCompanies.isEmpty)
    }

    func test_load_calledTwiceWithoutRetry_doesNotCallServiceTwice() async {
        let (vm, mock) = makeVM(stub: .success(makeJobs()))

        await vm.load()
        await vm.load()

        XCTAssertEqual(mock.callCount, 1, "Não deve chamar o service se já tem dados carregados")
    }

    func test_retry_afterError_callsServiceAgain() async {
        let (vm, mock) = makeVM(stub: .failure(NetworkError.offline))

        await vm.load()
        XCTAssertEqual(mock.callCount, 1)

        await vm.retry()
        XCTAssertGreaterThanOrEqual(mock.callCount, 1, "Retry deve chamar o service de novo")
    }

    func test_initialState_isIdle() {
        let (vm, _) = makeVM(stub: .success([]))
        XCTAssertEqual(vm.state, .idle)
    }

    // MARK: - Tests: Aggregation (regras de negócio do VM)

    func test_aggregate_categoriesAreGroupedByLowercaseName() {
        let jobs: [RemotiveJobDTO] = [
            .makeStub(id: 1, category: "Software Development"),
            .makeStub(id: 2, category: "software development"),
            .makeStub(id: 3, category: "Design")
        ]
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: jobs)

        XCTAssertEqual(data.topCategories.count, 2)
        XCTAssertEqual(data.topCategories.first?.count, 2, "Categorias com casing diferente devem ser agrupadas")
    }

    func test_aggregate_skillsCountedAcrossAllJobs() {
        let jobs: [RemotiveJobDTO] = [
            .makeStub(id: 1, tags: ["swift", "react"]),
            .makeStub(id: 2, tags: ["React", "AWS"]),
            .makeStub(id: 3, tags: ["swift", "aws"])
        ]
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: jobs)

        XCTAssertEqual(data.topSkills.count, 3)
        XCTAssertEqual(data.topSkills.first(where: { $0.name == "react" })?.count, 2)
        XCTAssertEqual(data.topSkills.first(where: { $0.name == "aws" })?.count, 2)
        XCTAssertEqual(data.topSkills.first(where: { $0.name == "swift" })?.count, 2)
    }

    func test_aggregate_companiesGroupedByName() {
        let jobs: [RemotiveJobDTO] = [
            .makeStub(id: 1, company: "GitHub"),
            .makeStub(id: 2, company: "github"),   // lowercase — mesma empresa
            .makeStub(id: 3, company: "Shopify")
        ]
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: jobs)

        XCTAssertEqual(data.topCompanies.count, 2)
        XCTAssertEqual(data.topCompanies.first?.count, 2)
    }

    func test_aggregate_limitsRespected() {
        let jobs: [RemotiveJobDTO] = (0..<20).map { element in
            .makeStub(id: element, category: "Cat \(i % 7)", tags: ["tag\(i % 11)"])
        }
        let vm = MarketPulseViewModel(
            service: MockMarketPulseService(stub: .success([])),
            categoryLimit: 3,
            skillLimit: 4,
            companyLimit: 2
        )

        let data = vm.aggregate(jobs: jobs)

        XCTAssertLessThanOrEqual(data.topCategories.count, 3)
        XCTAssertLessThanOrEqual(data.topSkills.count, 4)
        XCTAssertLessThanOrEqual(data.topCompanies.count, 2)
    }

    func test_aggregate_resultsOrderedByCountDesc() {
        let jobs: [RemotiveJobDTO] = [
            .makeStub(id: 1, category: "A"),
            .makeStub(id: 2, category: "B"),
            .makeStub(id: 3, category: "B"),
            .makeStub(id: 4, category: "B"),
            .makeStub(id: 5, category: "C")
        ]
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: jobs)

        XCTAssertEqual(data.topCategories.map(\.count), [3, 1, 1])
    }

    func test_aggregate_prettyCaseAppliedToCategoryNames() {
        let jobs: [RemotiveJobDTO] = [
            .makeStub(id: 1, category: "software development")
        ]
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: jobs)

        XCTAssertEqual(data.topCategories.first?.name, "Software Development")
    }

    func test_aggregate_emptyJobs_producesEmptyAggregations() {
        let vm = MarketPulseViewModel(service: MockMarketPulseService(stub: .success([])))

        let data = vm.aggregate(jobs: [])

        XCTAssertEqual(data.totalJobs, 0)
        XCTAssertTrue(data.topCategories.isEmpty)
        XCTAssertTrue(data.topSkills.isEmpty)
        XCTAssertTrue(data.topCompanies.isEmpty)
    }
}
