
//
//  MockAPIClient.swift
//  VacancyModuleTests
//
//  Mock do APIClientProtocol. Usado nos testes de Middleware e Store.
//
//  Por que `actor`? O protocol exige `Sendable`. Actor é auto-Sendable
//  e protege contra race conditions em testes async.
//

import Foundation
import NetworkLayer

actor MockAPIClient: APIClientProtocol {

    private(set) var requestCount: Int = 0
    private var stub: (() async throws -> any Sendable)?
    /// Configura o mock pra retornar `value` com sucesso.
    func stubSuccess<T: Decodable & Sendable>(_ value: T) {
        stub = { value }
    }

    /// Configura o mock pra lançar `error`.
    func stubFailure(_ error: Error) {
        stub = { throw error }
    }

    /// Última URL recebida — útil pra asserts "chamou a URL certa?".
    private(set) var lastRequestType: RequestType?

    func request<Model: Decodable & Sendable>(
        requestType: RequestType
    ) async throws -> Model {
        requestCount += 1
        lastRequestType = requestType

        guard let stub else {
            throw NetworkError.genericError
        }

        let result = try await stub()
        guard let typed = result as? Model else {
            throw NetworkError.genericError
        }
        return typed
    }

    func cancelAllTasks() async {
        // no-op
    }
}
