//
//  RemotiveHost.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 17/07/26.
//


//
//  RemotiveEndpoint.swift
//  MarketPulseModule
//
//  Endpoint da Remotive.
//  Segue o padrão `EndpointType` que o `VacancyView` já usa pro Arbeitnow.
//

import Foundation
import NetworkLayer

public struct RemotiveHost: HostTypeService {
    public init() {}
    public func getHost() async -> String { "remotive.com" }
    public func getDescription() async -> [String: Any] { [:] }
}

public enum RemotiveEndpoint: EndpointType {
    public static var hostType: HostTypeService { RemotiveHost() }
    case jobs(limit: Int)
    public var path: String {
        switch self {
        case .jobs:
            return "/api/remote-jobs"
        }
    }
    
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .jobs(let limit):
            return [URLQueryItem(name: "limit", value: String(limit))]
        }
    }
}

public protocol MarketPulseServiceProtocol: Sendable {
    func fetchPulse(limit: Int) async throws -> RemotiveJobsResponseDTO
}

public struct MarketPulseService: MarketPulseServiceProtocol {

    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    public func fetchPulse(limit: Int) async throws -> RemotiveJobsResponseDTO {
        let request = try await RequestType.build(
            url: RemotiveEndpoint.jobs(limit: limit).url(),
            method: .get
        )
        return try await apiClient.request(requestType: request)
    }
}
