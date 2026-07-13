//
//  Configurations.swift
//  spGovBr
//
//  Created by Gabriel Gonçalves Guimarães on 23/05/23.
//

import Foundation

public enum EnvironmentModeApp: Sendable {
    case production
    case homolog
    case desenv
}

public struct Config {
    nonisolated(unsafe)
    public static var environment: EnvironmentModeApp = .homolog
}
