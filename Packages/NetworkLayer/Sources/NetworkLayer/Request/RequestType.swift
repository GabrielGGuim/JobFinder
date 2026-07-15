//
//  RequestType.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//

import Foundation

import Foundation

public struct RequestType: Sendable {

    public let url: URL?
    public let method: HTTPMethod
    public let body: Data?
    public let headers: [String: String]
    public let timeoutInterval: Double

    public enum HTTPMethod: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    var request: URLRequest {
        get throws {
            try getURLRequest()
        }
    }

    public init(
        url: URL?,
        method: HTTPMethod = .get,
        body: Data? = nil,
        headers: [String: String] = [:],
        timeoutInterval: Double = 60
    ) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
        self.timeoutInterval = timeoutInterval
    }

    /// Cria um RequestType serializando automaticamente um objeto JSON.
    public static func build(
        url: URL?,
        parameters: Any? = nil,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        timeoutInterval: Double = 60
    ) throws -> RequestType {

        let body: Data?

        if let parameters {
            body = try JSONSerialization.data(withJSONObject: parameters)
        } else {
            body = nil
        }

        return RequestType(
            url: url,
            method: method,
            body: body,
            headers: headers,
            timeoutInterval: timeoutInterval
        )
    }
}

private extension RequestType {

    func getURLRequest() throws -> URLRequest {

        guard let url else {
            throw NetworkError.genericError
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.httpBody = body

        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        return request
    }
}
