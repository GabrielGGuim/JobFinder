//
//  APIClientProtocol.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//


import Foundation

public protocol APIClientProtocol: Sendable {

    func request<Model: Decodable & Sendable>(
        requestType: RequestType
    ) async throws -> Model

    func cancelAllTasks() async
}

public actor APIClient: APIClientProtocol {

    public static let shared = APIClient()

    private let urlSession: URLSession

    private init() {
        urlSession = URLSession(configuration: .default)
    }

    public func request<Model: Decodable & Sendable>(
        requestType: RequestType
    ) async throws -> Model {

        do {

            let request = try requestType.request

            let (data, response) = try await urlSession.data(for: request)

            await printRequest(
                req: request,
                response: response,
                data: data
            )

            try await ErrorVerifier.build(
                from: response,
                data: data
            )

            return try data.build(to: Model.self)

        } catch {

            throw ErrorVerifier.build(from: error)
        }
    }

    private func printRequest(
        req: URLRequest,
        response: URLResponse?,
        data: Data?
    ) async {

        guard await NetworkLayer.shared.showLog else {
            return
        }

        debugPrint("*+*+**+*+*+*+*+*+*+*+*")
        print("Request Method:")
        print(req.httpMethod ?? "")
        print("Request URL:")
        print(req.url ?? "")
        print("Request Headers:")
        print(req.allHTTPHeaderFields ?? "")
        print("Request Body:")
        print(String(data: req.httpBody ?? Data(), encoding: .utf8) ?? "")
        print("Response Code:")
        print((response as? HTTPURLResponse)?.statusCode ?? "")
        print("Response Body:")
        print(String(data: data ?? Data(), encoding: .utf8) ?? "")
        debugPrint("*+*+**+*+*+*+*+*+*+*+*\n")
    }

    public func cancelAllTasks() async {
        let tasks = await urlSession.allTasks
        tasks.forEach { $0.cancel() }
    }
}
