//
//  VacancyListStoreTests.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//
import XCTest
@testable import VacancyModule
import NetworkLayer

@MainActor
final class VacancyListStoreTests: XCTestCase {

    // MARK: - Fixtures

    private func makeJob(slug: String, title: String = "iOS Dev") -> JobDTO {
        return JobDTO(
            slug: slug,
            companyName: "Google",
            title: title,
            description: "Backend Engineer",
            remote: false,
            url: "https://google.com/jobs/2",
            tags: ["Backend", "Engineering"],
            jobTypes: ["Full Time"],
            location: "Berlin",
            createdAt: 1_783_711_900
        )
    }

    private func makeResponse(jobs: [JobDTO]) -> VacanciesResponseDTO {
        VacanciesResponseDTO(
            data: jobs,
            meta: .init(currentPage: 1, perPage: 10, lastPage: 1, total: jobs.count)
        )
    }

    // Pequeno helper pra esperar o middleware async terminar.
    // No mercado, isso pode ser feito com XCTestExpectation + fulfill,
    // mas `Task.sleep` é mais simples e suficiente pra testes de Store.
    private func esperarMiddlewareCompletar() async {
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        // Duas passadas de yield pra garantir que o Task @MainActor rodou
        await Task.yield()
        await Task.yield()
    }

    // MARK: - onAppear fluxo completo (success)

    func test_onAppear_quandoAPIRetornaSucesso_devePopularStateComJobs() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubSuccess(makeResponse(jobs: [
            makeJob(slug: "1"),
            makeJob(slug: "2"),
        ]))
        let store = VacancyListStore.make(apiClient: mock)

        // Act
        store.send(.onAppear)
        await esperarMiddlewareCompletar()

        // Assert
        XCTAssertEqual(store.state.jobs.count, 2)
        XCTAssertEqual(store.state.jobs.map(\.slug), ["1", "2"])
        XCTAssertFalse(store.state.loading, "Loading deveria ter sido desligado")
        XCTAssertNil(store.state.error)
    }

    func test_onAppear_quandoExecutado_deveAtivarLoadingImediatamente() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubSuccess(makeResponse(jobs: []))
        let store = VacancyListStore.make(apiClient: mock)

        // Act — mas sem esperar o middleware terminar
        store.send(.onAppear)
        // Não damos tempo do middleware rodar. O reducer JÁ foi executado
        // no `send` (síncrono), então o loading=true já está no state.

        // Assert
        XCTAssertTrue(store.state.loading,
                      "Imediatamente após send(.onAppear), loading deveria ser true (efeito do reducer síncrono)")
    }

    // MARK: - onAppear fluxo completo (error)

    func test_onAppear_quandoAPIRetornaErro_deveSetarMensagemDeErroNoState() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubFailure(NetworkError.custom("deu ruim"))
        let store = VacancyListStore.make(apiClient: mock)

        // Act
        store.send(.onAppear)
        await esperarMiddlewareCompletar()

        // Assert
        XCTAssertEqual(store.state.error, "deu ruim")
        XCTAssertFalse(store.state.loading)
        XCTAssertTrue(store.state.jobs.isEmpty)
    }

    // MARK: - Actions síncronas (não disparam middleware)

    func test_search_quandoExecutado_deveAtualizarSearchTextSincronamente() {
        // Arrange
        let mock = MockAPIClient()
        let store = VacancyListStore.make(apiClient: mock)

        // Act
        store.send(.search("iOS Pleno"))

        // Assert — sem precisar de await porque search não dispara middleware
        XCTAssertEqual(store.state.searchText, "iOS Pleno")
    }

    func test_selectTag_quandoExecutado_deveAtualizarTagSelecionadaSincronamente() {
        // Arrange
        let mock = MockAPIClient()
        let store = VacancyListStore.make(apiClient: mock)

        // Act
        store.send(.selectTag("kotlin"))

        // Assert
        XCTAssertEqual(store.state.selectedTag, "kotlin")
    }

    // MARK: - Integração: search após fetch funciona end-to-end

    func test_searchAposFetch_deveFiltrarJobsCarregados() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubSuccess(makeResponse(jobs: [
            makeJob(slug: "1", title: "iOS Senior"),
            makeJob(slug: "2", title: "Android Senior"),
        ]))
        let store = VacancyListStore.make(apiClient: mock)

        // Act
        store.send(.onAppear)
        await esperarMiddlewareCompletar()

        XCTAssertEqual(store.state.jobs.count, 2, "Pré-condição: 2 jobs carregados")

        store.send(.search("ios"))

        // Assert
        XCTAssertEqual(store.state.filteredJobs.map(\.slug), ["1"])
    }

    // MARK: - State inicial

    func test_storeInicial_deveTerStateZerado() {
        let mock = MockAPIClient()
        let store = VacancyListStore.make(apiClient: mock)

        XCTAssertTrue(store.state.jobs.isEmpty)
        XCTAssertFalse(store.state.loading)
        XCTAssertNil(store.state.error)
        XCTAssertEqual(store.state.selectedTag, "All")
        XCTAssertEqual(store.state.searchText, "")
    }
}
