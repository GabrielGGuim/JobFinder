//
//  HostTypeService.swift
//  NetworkLayer
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//


import Foundation

import Foundation

public protocol HostTypeService {
    func getHost() async -> String
    func getDescription() async -> [String: Any]
}

public protocol EndpointType {
    static var hostType: HostTypeService { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

public extension EndpointType {
    var queryItems: [URLQueryItem]? { nil }

    func url() async -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = await Self.hostType.getHost()
        components.path = path
        components.queryItems = queryItems
        return components.url
    }

    static func header() async -> [String: Any] {
        await hostType.getDescription()
    }
}
