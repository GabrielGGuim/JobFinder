//
//  RemotiveJobDTO.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 16/07/26.
//

import Foundation
import Extensions

public struct RemotiveJobsResponseDTO: Codable, Sendable {
    let the00Warning, the0LegalNotice: String?
    let jobCount, totalJobCount: Int?
    let jobs: [JobResponseDTO]?
    
    enum CodingKeys: String, CodingKey {
        case the00Warning = "00-warning"
        case the0LegalNotice = "0-legal-notice"
        case jobCount = "job-count"
        case totalJobCount = "total-job-count"
        case jobs
    }
}

// MARK: - Job
struct JobResponseDTO: Codable, Sendable {
    let id: Int?
    let url: String?
    let title, companyName: String?
    let companyLogo: String?
    let category: String?
    let tags: [String]?
    let jobType: JobType?
    let publicationDate: Date?
    let candidateRequiredLocation, salary, description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url, title
        case companyName = "company_name"
        case companyLogo = "company_logo"
        case category, tags
        case jobType = "job_type"
        case publicationDate = "publication_date"
        case candidateRequiredLocation = "candidate_required_location"
        case salary, description
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id          = try container.decode(Int.self, forKey: .id)
        self.url         = try container.decode(String.self, forKey: .url)
        self.title       = try container.decode(String.self, forKey: .title)
        self.companyName = try container.decode(String.self, forKey: .companyName)
        self.companyLogo = try container.decodeIfPresent(String.self, forKey: .companyLogo)
        self.category    = try container.decode(String.self, forKey: .category)
        self.tags        = (try? container.decode([String].self, forKey: .tags)) ?? []
        self.jobType     = try container.decodeIfPresent(JobType.self, forKey: .jobType)
        
        // publication_date às vezes vem ISO 8601, às vezes vem vazio.
        if let raw = try? container.decode(String.self, forKey: .publicationDate),
           !raw.isEmpty {
            self.publicationDate = DateFormatter.iso8601.date(from: raw)
        } else {
            self.publicationDate = nil
        }
        
        self.candidateRequiredLocation = try container.decodeIfPresent(String.self, forKey: .candidateRequiredLocation)
        self.salary        = try container.decodeIfPresent(String.self, forKey: .salary)
        self.description   = try container.decodeIfPresent(String.self, forKey: .description)
    }
}

extension JobResponseDTO {
    
    /// "Há 2 dias" / "Há 5 horas" / "Agora" / "—" se não tem data.
    var relativePublicationTime: String {
        guard let date = publicationDate else { return "—" }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "agora" }
        if interval < 3_600 { return "há \(Int(interval / 60)) min" }
        if interval < 86_400 { return "há \(Int(interval / 3_600))h" }
        return "há \(Int(interval / 86_400))d"
    }
    
    /// "🌍 Worldwide" / "🌍 Remote" / o que vier.
    var locationLabel: String {
        guard let raw = candidateRequiredLocation, !raw.isEmpty else { return "🌍 Remote" }
        return "🌍 \(raw)"
    }
}
enum JobType: String, Codable, Sendable {
    case contract = "contract"
    case freelance = "freelance"
    case fullTime = "full_time"
    case partTime = "part_time"
}
