//
//  MarketPulseViewState.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 17/07/26.
//


import Foundation

public enum MarketPulseViewState: Equatable {

    case idle

    case loading

    case loaded(MarketPulseData)

    case error(String)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var data: MarketPulseData? {
        if case .loaded(let data) = self { return data }
        return nil
    }

    public var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}
