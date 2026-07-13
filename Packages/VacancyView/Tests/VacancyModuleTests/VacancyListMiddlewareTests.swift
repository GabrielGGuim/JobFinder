//
//  VacancyListMiddlewareTests.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//
import XCTest
@testable import VacancyModule
import NetworkLayer

final class VacancyListMiddlewareTests: XCTestCase {

    // MARK: - Fixtures

    private func makeJob(slug: String) -> JobDTO {
        return JobDTO(
            slug: slug,
            companyName: "Google",
            title: "Backend Engineer",
            description: "Backend Engineer",
            remote: false,
            url: "https://google.com/jobs/2",
            tags: ["Backend", "Engineering"],
            jobTypes: ["Full Time"],
            location: "Berlin",
            createdAt: 1_783_711_900
        )
    }

    private func makeResponse(jobs: [JobDTO] = []) -> VacanciesResponseDTO {
        VacanciesResponseDTO(
            data: jobs,
            meta: .init(currentPage: 1, perPage: 10, lastPage: 1, total: jobs.count)
        )
    }

    // MARK: - onAppear → success

    func test_onAppear_quandoAPIRetornaSucesso_deveRetornarFetchSucceeded() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubSuccess(makeResponse(jobs: [makeJob(slug: "1")]))
        let middleware = makeVacancyListMiddleware(apiClient: mock)
        let state = VacancyListState()

        // Act
        let result = await middleware(state, .onAppear)

        // Assert
        guard case .fetchSucceeded(let response) = result else {
            XCTFail("Esperava .fetchSucceeded, recebi \(String(describing: result))")
            return
        }
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.slug, "1")

        let count = await mock.requestCount
        XCTAssertEqual(count, 1, "Era esperado exatamente 1 chamada à API")
    }

    // MARK: - onAppear → error NetworkError

    func test_onAppear_quandoAPIRetornaNetworkErrorCustom_deveRetornarFetchFailedComMensagem() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubFailure(NetworkError.custom("timeout"))
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        // Act
        let result = await middleware(VacancyListState(), .onAppear)

        // Assert
        guard case .fetchFailed(let message) = result else {
            XCTFail("Esperava .fetchFailed, recebi \(String(describing: result))")
            return
        }
        XCTAssertEqual(message, "timeout")
    }

    func test_onAppear_quandoAPIRetornaNetworkErrorGenerico_deveRetornarFetchFailedGenerico() async {
        // Arrange
        let mock = MockAPIClient()
        await mock.stubFailure(NetworkError.genericError)
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        // Act
        let result = await middleware(VacancyListState(), .onAppear)

        // Assert
        guard case .fetchFailed(let message) = result else {
            XCTFail("Esperava .fetchFailed, recebi \(String(describing: result))")
            return
        }
        // NetworkError.genericError.errorDescription = "Esse serviço está indisponível"
        XCTAssertEqual(message, "Esse serviço está indisponível")
    }

    // MARK: - onAppear → erro genérico (não-NetworkError)

    func test_onAppear_quandoErroGenericoNaoNetwork_deveRetornarFetchFailedGenerico() async {
        // Arrange
        let mock = MockAPIClient()
        struct WeirdError: Error {}
        await mock.stubFailure(WeirdError())
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        // Act
        let result = await middleware(VacancyListState(), .onAppear)

        // Assert
        guard case .fetchFailed(let message) = result else {
            XCTFail("Esperava .fetchFailed, recebi \(String(describing: result))")
            return
        }
        XCTAssertEqual(message, "Não foi possível carregar as vagas.")
    }

    // MARK: - Actions que NÃO disparam fetch

    func test_selectTag_quandoExecutado_naoDeveChamarAPI() async {
        let mock = MockAPIClient()
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        let result = await middleware(VacancyListState(), .selectTag("swift"))

        XCTAssertNil(result, "selectTag não deveria retornar action")
        let count = await mock.requestCount
        XCTAssertEqual(count, 0, "selectTag não deveria chamar a API")
    }

    func test_search_quandoExecutado_naoDeveChamarAPI() async {
        let mock = MockAPIClient()
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        let result = await middleware(VacancyListState(), .search("iOS"))

        XCTAssertNil(result)
        let count = await mock.requestCount
        XCTAssertEqual(count, 0)
    }

    func test_fetchSucceeded_quandoRecebidoDeVolta_naoDeveChamarAPI() async {
        let mock = MockAPIClient()
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        let result = await middleware(
            VacancyListState(),
            .fetchSucceeded(makeResponse(jobs: [makeJob(slug: "x")]))
        )

        XCTAssertNil(result, "fetchSucceeded não deveria gerar nova action")
        let count = await mock.requestCount
        XCTAssertEqual(count, 0)
    }

    func test_fetchFailed_quandoRecebidoDeVolta_naoDeveChamarAPI() async {
        let mock = MockAPIClient()
        let middleware = makeVacancyListMiddleware(apiClient: mock)

        let result = await middleware(VacancyListState(), .fetchFailed("erro"))

        XCTAssertNil(result)
        let count = await mock.requestCount
        XCTAssertEqual(count, 0)
    }
}
