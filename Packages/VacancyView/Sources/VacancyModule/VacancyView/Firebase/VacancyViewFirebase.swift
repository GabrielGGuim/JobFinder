//
//  VacancyButton.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 12/07/26.
//
import FirebaseData

public enum VacancyViewFirebase: String, FirebaseAnalyticsEvent {
    public var title: String {
        switch self {
        case .tapJob:
            return "tap job"
        case .tapFilter:
            return "tap filter"
        case .tapSearch:
            return "tap search"
        case .tapApply:
            return "tapApply"
        }
    }
    
    public var type: FirebaseData.FirebaseScreenTypeEvent {
        switch self {
        case .tapJob:
            return .button
        case .tapFilter:
            return .button
        case .tapSearch:
            return .screen
        case .tapApply:
            return .button
        }
    }
    
    case tapJob
    case tapFilter
    case tapSearch
    case tapApply
}
