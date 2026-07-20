//
//  MarketPulseData.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 17/07/26.
//

import Foundation
import Components

public struct MarketPulseData: Equatable, Sendable {

    public let totalJobs: Int

    public let topCategories: [CategoryCount]

    public let topSkills: [SkillCount]

    public let topCompanies: [CompanyCount]

    public init(
        totalJobs: Int,
        topCategories: [CategoryCount],
        topSkills: [SkillCount],
        topCompanies: [CompanyCount]
    ) {
        self.totalJobs = totalJobs
        self.topCategories = topCategories
        self.topSkills = topSkills
        self.topCompanies = topCompanies
    }
}

public struct CategoryCount: Equatable, Sendable, Identifiable, Hashable {
    public let name: String
    public let count: Int
    public var id: String { name }

    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

public struct SkillCount: Equatable, Sendable, Identifiable, Hashable {
    public let name: String
    public let count: Int
    public var id: String { name }

    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

public struct CompanyCount: Equatable, Sendable, Identifiable, Hashable, CompanyRowRepresentable {
    public let name: String
    public let count: Int
    public let logoURL: String?
    public let lastJobDate: Date?
    public let location: String
    public var id: String { name }

    public init(
        name: String,
        count: Int,
        logoURL: String?,
        lastJobDate: Date?,
        location: String
    ) {
        self.name = name
        self.count = count
        self.logoURL = logoURL
        self.lastJobDate = lastJobDate
        self.location = location
    }

    public var initials: String {
        let words = name
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .prefix(2)
        let letters = words.compactMap { $0.first }
        return String(letters).uppercased()
    }

    public var lastSeenLabel: String {
        guard let date = lastJobDate else { return "—" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "agora" }
        if interval < 3_600 { return "há \(Int(interval / 60)) min" }
        if interval < 86_400 { return "há \(Int(interval / 3_600))h" }
        return "há \(Int(interval / 86_400))d"
    }
}

extension MarketPulseData {
    static var skeleton: MarketPulseData {
        MarketPulseData(
            totalJobs: 0,
            topCategories: (0..<3)
                .map { CategoryCount(name: "placeholder-\($0)", count: 0)
            },
            topSkills: (0..<5)
                .map { SkillCount(name: "placeholder-\($0)", count: 0)
            },
            topCompanies: (0..<3)
                .map { CompanyCount(name: "placeholder-\($0)", count: 0, logoURL: nil, lastJobDate: nil, location: "")
            }
        )
    }
}
