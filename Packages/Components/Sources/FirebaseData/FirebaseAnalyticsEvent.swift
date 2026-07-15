//
//  FirebaseEventProtocol.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 21/05/25.
//

import Foundation
import Settings

public protocol FirebaseAnalyticsEvent {
    var id: String { get }
    var title: String { get }
    var type: FirebaseScreenTypeEvent { get }
    var additionalParameters: [String: Any]? { get }

    func collection(for environment: EnvironmentModeApp) -> String
}

public enum FirebaseScreenTypeEvent: String {
    case button = "Button"
    case screen = "Screen"
}

// MARK: Make properties optional
extension FirebaseAnalyticsEvent where Self: RawRepresentable, Self.RawValue == String {
    public var id: String { rawValue }
}

extension FirebaseAnalyticsEvent {
    public var additionalParameters: [String: Any]? { nil }

    public func collection(for environment: EnvironmentModeApp) -> String {
        switch environment {
        case .homolog, .desenv:
            return "event_page_views_homolog"
        case .production:
            return "event_page_views"
        }
    }
}
