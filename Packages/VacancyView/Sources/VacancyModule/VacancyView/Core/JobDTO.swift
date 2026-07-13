//
//  JobDTO.swift
//  VacancyModule
//
//  DTO = Data Transfer Object. É o "shape" do JSON da Arbeitnow.
//  Decodable porque a API entrega JSON e a gente precisa transformar em struct.
//
//  Esses campos batem 1-pra-1 com o payload real da API:
//      https://www.arbeitnow.com/api/job-board-api
//
//  CodingKeys é o que faz a ponte entre Swift (camelCase) e JSON (snake_case).
//

import Foundation
import Extensions

public struct JobDTO: Decodable, Sendable, Hashable {
    public let slug: String
    public let companyName: String
    public let title: String
    public let description: String
    public let remote: Bool
    public let url: String
    public let tags: [String]
    public let jobTypes: [String]
    public let location: String
    public let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case slug
        case companyName = "company_name"
        case title
        case description
        case remote
        case url
        case tags
        case jobTypes = "job_types"
        case location
        case createdAt = "created_at"
    }

    public init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)
        slug         = try decoder.decode(String.self, forKey: .slug)
        companyName  = try decoder.decode(String.self, forKey: .companyName)
        title        = try decoder.decode(String.self, forKey: .title)
        description  = try decoder.decode(String.self, forKey: .description)

        // A API às vezes devolve `remote` como Bool, às vezes como "true"/"false".
        // Pra ser tolerante, tenta os dois.
        if let boolValue = try? decoder.decode(Bool.self, forKey: .remote) {
            remote = boolValue
        } else if let stringValue = try? decoder.decode(String.self, forKey: .remote) {
            remote = (stringValue.lowercased() == "true")
        } else {
            remote = false
        }

        url        = try decoder.decode(String.self, forKey: .url)
        tags       = (try? decoder.decode([String].self, forKey: .tags))      ?? []
        jobTypes   = (try? decoder.decode([String].self, forKey: .jobTypes))   ?? []
        location   = try decoder.decode(String.self, forKey: .location)
        createdAt  = try decoder.decode(Int.self,    forKey: .createdAt)
    }
    
    public init(
        slug: String,
        companyName: String,
        title: String,
        description: String,
        remote: Bool,
        url: String,
        tags: [String],
        jobTypes: [String],
        location: String,
        createdAt: Int
    ) {
        self.slug = slug
        self.companyName = companyName
        self.title = title
        self.description = description
        self.remote = remote
        self.url = url
        self.tags = tags
        self.jobTypes = jobTypes
        self.location = location
        self.createdAt = createdAt
    }
}

/// Envelope da resposta da Arbeitnow.
/// Ex: { "data": [JobDTO...], "links": {...}, "meta": {...} }
public struct VacanciesResponseDTO: Decodable, Sendable {
    public let data: [JobDTO]
    public let meta: MetaDTO

    public struct MetaDTO: Decodable, Sendable {
        public let currentPage: Int
        public let perPage: Int
        public let lastPage: Int?
        public let total: Int?

        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case perPage     = "per_page"
            case lastPage    = "last_page"
            case total
        }
    }
}

extension JobDTO {

    static func placeholders(count: Int) -> [JobDTO] {
        (0..<count).map { index in
            JobDTO(
                slug: "placeholder-\(index)────────────",
                companyName: "────────────────────────",
                title: "────────────────────────────────",
                description: "",
                remote: false,
                url: "────────────",
                tags: ["────────────────────"],
                jobTypes: ["────────────────────────"],
                location: "────────────────────────",
                createdAt: 0
            )
        }
    }
}

// MARK: - Helpers de apresentação

public extension JobDTO {

    /// "Há 2 dias", "Há 5 horas", "Agora" — vem do `createdAt` (timestamp unix).
    var relativeTime: String {
        return createdAt.asRelativeTimeString
    }
    /// Tira tags HTML do description (que vem com `<p>`, `<strong>`, etc.).
    /// Não é perfeito, mas serve pra preview.
    var descriptionStripped: String {
        return description.htmlStripped
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Localização legível. Se for remote, prioriza "Remoto".
    var displayLocation: String {
        remote ? "Remote" : location
    }
}
