//
//  FirebaseConfig.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 21/05/25.
//

@preconcurrency import FirebaseFirestore
import SwiftUI
import Settings

final public class FirebaseConfig: Sendable {
    
    // MARK: - Private properties
    
    private let database = Firestore.firestore()
    
    // MARK: - Public properties
    
    public static let shared = FirebaseConfig()
    
    // MARK: - Internal methods
    
    public func save(_ event: FirebaseAnalyticsEvent) async {
        do {
            try await database
                .collection(event.collection(for: Config.environment))
                .addDocument(data: dataDictionary(ofType: .event(event: event)))
            
            print("Analytics(EVENT) --> \(event.title)")
        } catch {
            print("Firestore Error:", error)
        }
    }

    private func dataDictionary(ofType type: SaveType) -> [String: Any] {
        var data: [String: Any] = [
            "date_hour": {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                formatter.timeZone = TimeZone(identifier: "UTC")
                return formatter.string(from: Date())
            }(),
            "region": String(describing: Locale.current.region?.identifier ?? String()),
            "platform": "ios",
            "title": type.title,
            "type": type.type,
            type.rawValue: type.id
        ]
        type.aditionalParameters?.forEach { data[$0.key] = $0.value }
        print(data)
        return data
    }
}

extension FirebaseConfig {
    enum SaveType {
        case screen(screen: FirebaseAnalyticsEvent), event(event: FirebaseAnalyticsEvent)
        
        var title: String {
            switch self {
            case .event(let event):
                return event.title
            case .screen(let screen):
                return screen.title
            }
        }
        
        var rawValue: String {
            switch self {
            case .screen: 
                return "ID_Screen"
            case .event:
                return "ID_Button"
            }
        }
        
        var id: String {
            switch self {
            case .event(let event):
                return event.id
            case .screen(let screen):
                return screen.id
            }
        }
        
        var type: String {
            switch self {
            case .screen(let screen):
                return screen.type.rawValue
            case .event:
                return "Button"
            }
        }
        
        var aditionalParameters: [String: Any]? {
            switch self {
            case .event(let event):
                return event.additionalParameters
            case .screen(let screen):
                return screen.additionalParameters
            }
        }
    }
}
