//
//  VacancyListStateTests.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//


import XCTest
@testable import VacancyModule

final class VacancyListStateTests: XCTestCase {
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
    
    func test_filteredJobs_quandoListaVazia_deveRetornarVazio() {
        let state = VacancyListState()
        XCTAssertTrue(state.filteredJobs.isEmpty)
    }
    func test_filteredJobs_quandoTagAllESemSearch_deveRetornarTodosOsJobs() {
        var state = VacancyListState()
        state.jobs = [VacancyListStateTests.makeJob(slug: "1"), VacancyListStateTests.makeJob(slug: "2"), VacancyListStateTests.makeJob(slug: "3")]
        // selectedTag default = "All", searchText default = ""
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1", "2", "3"])
    }
    
    func test_filteredJobs_quandoTagEspecifica_deveRetornarApenasJobsComATag() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", tags: ["swift"]),
            VacancyListStateTests.makeJob(slug: "2", tags: ["kotlin"]),
            VacancyListStateTests.makeJob(slug: "3", tags: ["swift", "ios"]),
        ]
        state.selectedTag = "swift"
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1", "3"])
    }
    
    func test_filteredJobs_quandoTagInexistente_deveRetornarVazio() {
        var state = VacancyListState()
        state.jobs = [VacancyListStateTests.makeJob(slug: "1", tags: ["swift"])]
        state.selectedTag = "ruby"
        
        XCTAssertTrue(state.filteredJobs.isEmpty)
    }
    
    func test_filteredJobs_quandoSearchPorTitulo_deveSerCaseInsensitive() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", title: "iOS Developer"),
            VacancyListStateTests.makeJob(slug: "2", title: "Android Dev"),
        ]
        state.searchText = "ios"
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1"])
    }
    
    func test_filteredJobs_quandoSearchPorCompanhia_deveEncontrar() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", companyName: "Globant"),
            VacancyListStateTests.makeJob(slug: "2", companyName: "Nubank"),
        ]
        state.searchText = "globant"
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1"])
    }
    
    func test_filteredJobs_quandoSearchComWhitespaceNasBordas_deveTrimmar() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", title: "iOS Dev"),
            VacancyListStateTests.makeJob(slug: "2", title: "Android"),
        ]
        state.searchText = "   ios   "
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1"])
    }
    
    func test_filteredJobs_quandoSearchVazia_deveRetornarTodos() {
        var state = VacancyListState()
        state.jobs = [VacancyListStateTests.makeJob(slug: "1"), VacancyListStateTests.makeJob(slug: "2")]
        state.searchText = "   "
        
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1", "2"])
    }
    
    func test_filteredJobs_quandoTagEBuscaCombinados_deveAplicarAmbosOsFiltros() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", title: "iOS Senior", tags: ["swift"]),
            VacancyListStateTests.makeJob(slug: "2", title: "iOS Junior", tags: ["kotlin"]),
            VacancyListStateTests.makeJob(slug: "3", title: "Android Senior", tags: ["swift"]),
        ]
        state.selectedTag = "swift"
        state.searchText = "ios"
        
        // Só "1" atende: tag=swift E título contém "ios"
        XCTAssertEqual(state.filteredJobs.map(\.slug), ["1"])
    }
    
    // MARK: - allTags
    
    func test_allTags_quandoListaVazia_deveRetornarApenasAll() {
        let state = VacancyListState()
        XCTAssertEqual(state.allTags, ["All"])
    }
    
    func test_allTags_quandoHaTags_deveRetornarAllMaisTagsUnicasOrdenadas() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", tags: ["swift", "ios"]),
            VacancyListStateTests.makeJob(slug: "2", tags: ["kotlin", "android"]),
            VacancyListStateTests.makeJob(slug: "3", tags: ["swift"]), // duplicata proposital
        ]
        
        XCTAssertEqual(state.allTags, ["All", "android", "ios", "kotlin", "swift"])
    }
    
    func test_allTags_quandoJobsSemTags_deveRetornarApenasAll() {
        var state = VacancyListState()
        state.jobs = [
            VacancyListStateTests.makeJob(slug: "1", tags: []),
            VacancyListStateTests.makeJob(slug: "2", tags: [])
        ]
        
        XCTAssertEqual(state.allTags, ["All"])
    }
    
    func test_allTags_sempreDeveComecarComAll() {
        var state = VacancyListState()
        state.jobs = [VacancyListStateTests.makeJob(slug: "1", tags: ["z", "a", "m"])]
        
        XCTAssertEqual(state.allTags.first, "All")
    }
}
