//
//  JobDTO.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 10/07/26.
//

//
//  VacancyListMiddleware.swift
//  VacancyModule
//
//  Middleware = "trabalho sujo". É onde mora a chamada HTTP,
//  a leitura de banco, etc. Recebe (state, action) e devolve
//  uma NOVA action (ex: ".fetchSucceeded" ou ".fetchFailed")
//  que vai ser mandada de volta pro Store.
//

import Foundation
import ReduxCore
import NetworkLayer

public func makeVacancyListMiddleware(apiClient: APIClientProtocol) -> @Sendable (VacancyListState, VacancyListAction) async -> VacancyListAction? {
    return { state, action in
        switch action {

        case .onAppear:
            return await fetch(page: 1, apiClient: apiClient)
        case .fetchSucceeded, .fetchFailed, .selectTag(_), .search(_), .pushJob(_), .popRoute, .popToRoot, .setRoutes(_):
            return nil
        }
    }
}

// MARK: - Fetch helper

private func fetch(
    page: Int,
    apiClient: APIClientProtocol
) async -> VacancyListAction {
    do {
        let request = try await RequestType.build(
            url: ArbeitnowAPI.vacancies(page: 1).url(),
            method: .get
        )
        let response: VacanciesResponseDTO = try await apiClient.request(
            requestType: request
        )
        return .fetchSucceeded(response)

    } catch let error as NetworkError {
        return .fetchFailed(error.errorDescription ?? "Erro desconhecido")

    } catch {
        return .fetchFailed("Não foi possível carregar as vagas.")
    }
}

public struct ArbeitnowHost: HostTypeService {
    public init() {}
    public func getHost() async -> String { "www.arbeitnow.com" }
    public func getDescription() async -> [String: Any] { [:] }
}

// MARK: - Endpoint
public enum ArbeitnowAPI: EndpointType {
    case vacancies(page: Int = 1)

    public static var hostType: HostTypeService { ArbeitnowHost() }

    public var path: String {
        switch self {
        case .vacancies:
            return "/api/job-board-api"
        }
    }

    public var queryItems: [URLQueryItem]? {
        switch self {
        case .vacancies(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        }
    }
}
