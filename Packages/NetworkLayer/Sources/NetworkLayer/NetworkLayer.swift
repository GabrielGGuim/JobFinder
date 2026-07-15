// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation

public actor NetworkLayer {

    public static let shared = NetworkLayer()

    private init() {}

    public var environment: EnvironmentMode = .production
    public var showLog = false

    public var httpResultAction: @Sendable (HttpResult) -> Void = { _ in }

    public func notify(_ result: HttpResult) {
        httpResultAction(result)
    }
}

public enum EnvironmentMode: Sendable {
    case production
    case homolog
}

