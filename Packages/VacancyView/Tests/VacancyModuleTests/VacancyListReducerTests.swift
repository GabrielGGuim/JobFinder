import XCTest
@testable import VacancyModule

final class VacancyListReducerTests: XCTestCase {
    
    static func makeJob(
        slug: String = "backend-engineer",
        companyName: String = "Google",
        title: String = "Backend Engineer",
        description: String = "Build scalable backend services.",
        remote: Bool = false,
        url: String = "https://google.com/jobs/2",
        tags: [String] = ["Backend", "Engineering"],
        jobTypes: [String] = ["Full Time"],
        location: String = "Berlin",
        createdAt: Int = 1_783_711_900
    ) -> JobDTO {
        
        return JobDTO(
            slug: slug,
            companyName: companyName,
            title: title,
            description: description,
            remote: remote,
            url: url,
            tags: tags,
            jobTypes: jobTypes,
            location: location,
            createdAt: createdAt
        )
    }
    
    func test_onAppear_quandoExecutado_deveMarcarLoadingComoTrue() {
        // Arrange
        let state = VacancyListState()
        // Estado inicial: loading=false, error=nil
        
        // Act
        let newState = vacancyListReducer(state, .onAppear)
        
        // Assert
        XCTAssertTrue(newState.loading, "Loading deveria estar true após onAppear")
        XCTAssertNil(newState.error, "Error deveria continuar nil após onAppear")
    }
    
    func test_pushJob_appendsRouteToStack() {
        // Arrange
        let state = VacancyListState()
        let job = VacancyListReducerTests.makeJob(slug: "1")
        // Act
        let newState = vacancyListReducer(state, .pushJob(job))
        
        XCTAssertEqual(newState.routes, [.jobDetail(job)])
    }
    
    func test_pushJob_twice_stacksRoutes() {
        var state = VacancyListState()
        let job1 = VacancyListReducerTests.makeJob(slug: "1")
        let job2 = VacancyListReducerTests.makeJob(slug: "2")
        
        
        state = vacancyListReducer(state, .pushJob(job1))
        state = vacancyListReducer(state, .pushJob(job2))
        
        XCTAssertEqual(state.routes, [.jobDetail(job1), .jobDetail(job2)])
    }
    
    func test_popRoute_removesLastRoute() {
        var state = VacancyListState()
        state.routes = [.jobDetail(VacancyListReducerTests.makeJob(slug: "1")), .jobDetail(VacancyListReducerTests.makeJob(slug: "2"))]
        
        state = vacancyListReducer(state, .popRoute)
        
        XCTAssertEqual(state.routes, [.jobDetail(VacancyListReducerTests.makeJob(slug: "1"))])
    }
    
    func test_popToRoot_clearsAllRoutes() {
        var state = VacancyListState()
        state.routes = [.jobDetail(VacancyListReducerTests.makeJob(slug: "1")), .jobDetail(VacancyListReducerTests.makeJob(slug: "2"))]
        
        state = vacancyListReducer(state, .popToRoot)
        
        XCTAssertTrue(state.routes.isEmpty)
    }
    
    
    func test_onAppear_quandoExecutado_naoDeveAlterarJobs() {
        // Arrange
        var state = VacancyListState()
        state.jobs = [VacancyListReducerTests.makeJob()]
        let jobsAntes = state.jobs
        
        // Act
        let newState = vacancyListReducer(state, .onAppear)
        
        // Assert
        XCTAssertEqual(newState.jobs, jobsAntes, "onAppear não deve mexer na lista de jobs")
    }
    
    func test_fetchSucceeded_quandoExecutado_deveConcatenarJobsNaLista() {
        // Arrange
        let state = VacancyListState()
        let response = VacanciesResponseDTO(
            data: [VacancyListReducerTests.makeJob(slug: "a"), VacancyListReducerTests.makeJob(slug: "b")],
            meta: .init(currentPage: 1, perPage: 10, lastPage: 5, total: 50)
        )
        
        // Act
        let newState = vacancyListReducer(state, .fetchSucceeded(response))
        
        // Assert
        XCTAssertEqual(newState.jobs.count, 2)
        XCTAssertEqual(newState.jobs.map(\.slug), ["a", "b"])
    }
    
    func test_fetchSucceeded_quandoExecutado_deveDesligarLoading() {
        // Arrange
        var state = VacancyListState()
        state.loading = true
        
        // Act
        let newState = vacancyListReducer(
            state,
            .fetchSucceeded(VacanciesResponseDTO(data: [], meta: .init(currentPage: 1, perPage: 10, lastPage: 1, total: 0)))
        )
        
        // Assert
        XCTAssertFalse(newState.loading)
    }
    
    func test_fetchSucceeded_quandoHaJobsExistentes_deveFazerAppendEPaginar() {
        // Arrange
        var state = VacancyListState()
        state.jobs = [VacancyListReducerTests.makeJob(slug: "old")]
        let response = VacanciesResponseDTO(
            data: [VacancyListReducerTests.makeJob(slug: "new1"), VacancyListReducerTests.makeJob(slug: "new2")],
            meta: .init(currentPage: 2, perPage: 10, lastPage: 5, total: 50)
        )
        
        // Act
        let newState = vacancyListReducer(state, .fetchSucceeded(response))
        
        // Assert
        XCTAssertEqual(newState.jobs.count, 3, "Era esperado 1 antigo + 2 novos")
        XCTAssertEqual(newState.jobs.map(\.slug), ["old", "new1", "new2"])
    }
    
    func test_fetchFailed_quandoExecutado_deveSetarMensagemDeErro() {
        // Arrange
        let state = VacancyListState()
        
        // Act
        let newState = vacancyListReducer(state, .fetchFailed("timeout"))
        
        // Assert
        XCTAssertEqual(newState.error, "timeout")
    }
    
    func test_fetchFailed_quandoExecutado_deveDesligarLoading() {
        // Arrange
        var state = VacancyListState()
        state.loading = true
        
        // Act
        let newState = vacancyListReducer(state, .fetchFailed("boom"))
        
        // Assert
        XCTAssertFalse(newState.loading)
    }
    
    func test_fetchFailed_quandoExecutado_naoDeveLimparJobs() {
        // Arrange
        var state = VacancyListState()
        state.jobs = [VacancyListReducerTests.makeJob()]
        
        // Act
        let newState = vacancyListReducer(state, .fetchFailed("erro"))
        
        // Assert
        XCTAssertEqual(newState.jobs.count, 1, "Erro NÃO deve limpar a lista existente")
    }
    
    func test_selectTag_quandoExecutado_deveAtualizarTagSelecionada() {
        // Arrange
        let state = VacancyListState()
        
        // Act
        let newState = vacancyListReducer(state, .selectTag("swift"))
        
        // Assert
        XCTAssertEqual(newState.selectedTag, "swift")
    }
    
    func test_search_quandoExecutado_deveAtualizarSearchText() {
        // Arrange
        let state = VacancyListState()
        
        // Act
        let newState = vacancyListReducer(state, .search("iOS Pleno"))
        
        // Assert
        XCTAssertEqual(newState.searchText, "iOS Pleno")
    }
    
    func test_reducer_naoDeveMutarOStateOriginal() {
        // Arrange
        let stateOriginal = VacancyListState()
        let snapshot = stateOriginal // struct, cópias são por valor
        
        // Act
        _ = vacancyListReducer(stateOriginal, .search("qualquer coisa"))
        
        // Assert
        XCTAssertEqual(stateOriginal.searchText, snapshot.searchText,
                       "Reducer MUTOU o state original — viola princípio do Redux!")
    }
}
