//
//  MarketPulseViewModel.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 17/07/26.
//

import Foundation
import NetworkLayer

@MainActor
public final class MarketPulseViewModel: ObservableObject {

    // MARK: - Public state

    @Published public private(set) var state: MarketPulseViewState = .idle

    // MARK: - Dependencies

    private let service: MarketPulseServiceProtocol
    private let jobsLimit: Int

    // Limites de agregação. São decisão de produto, então moram aqui.
    private let categoryLimit: Int
    private let skillLimit: Int
    private let companyLimit: Int

    // MARK: - Init

    public init(
        service: MarketPulseServiceProtocol = MarketPulseService(),
        jobsLimit: Int = 100,
        categoryLimit: Int = 5,
        skillLimit: Int = 10,
        companyLimit: Int = 5
    ) {
        self.service = service
        self.jobsLimit = jobsLimit
        self.categoryLimit = categoryLimit
        self.skillLimit = skillLimit
        self.companyLimit = companyLimit
    }

    // MARK: - Intents (entradas da View)

    /// Disparado no `.task` da View. Carrega os dados.
    public func load() async {
        // Evita disparo duplo se já tá carregando
        if case .loading = state { return }
        // Se já tem dados carregados, mantém (evita flicker).
        if case .loaded = state { return }

        state = .loading

        do {
            let response = try await service.fetchPulse(limit: jobsLimit)
            let data = aggregate(jobs: response.jobs ?? [])
            state = .loaded(data)
        } catch let error as NetworkError {
            state = .error(error.errorDescription ?? "Erro de rede desconhecido.")
        } catch {
            state = .error("Não foi possível carregar o mercado agora.")
        }
    }

    /// Disparado pelo botão "Tentar de novo" do estado de erro.
    public func retry() async {
        // Força reload: reset pro idle pra passar pelo guard do load().
        if case .error = state {
            state = .idle
        }
        await load()
    }

    // MARK: - Aggregation (regra de negócio)

    /// Transforma a lista bruta de vagas no agregado que a View consome.
    /// Função `internal` (não `private`) pra permitir testes diretos via `@testable import`.
    ///
    /// - As categorias são agrupadas case-insensitive (evita duplicar "Software Development" e "software development").
    /// - As skills são contadas em flatMap (cada job pode ter várias tags).
    /// - As empresas são agrupadas por nome, e mantemos a logo/data da vaga mais recente.
    /// - Todos os resultados são ordenados por count desc e limitados conforme os parâmetros.
    func aggregate(jobs: [JobResponseDTO]) -> MarketPulseData {
        MarketPulseData(
            totalJobs: jobs.count,
            topCategories: topCategories(from: jobs),
            topSkills: topSkills(from: jobs),
            topCompanies: topCompanies(from: jobs)
        )
    }

    // MARK: Aggregation helpers

    private func topCategories(from jobs: [JobResponseDTO]) -> [CategoryCount] {
        jobs
            .reduce(into: [String: Int]()) { acc, job in
                acc[job.category?.lowercased() ?? "", default: 0] += 1
            }
            .map { CategoryCount(name: prettyCase($0.key), count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(categoryLimit)
            .map { $0 }
    }

    private func topSkills(from jobs: [JobResponseDTO]) -> [SkillCount] {
        jobs
            .flatMap { $0.tags ?? [] }
            .map { $0.lowercased() }
            .reduce(into: [String: Int]()) { acc, tag in
                acc[tag, default: 0] += 1
            }
            .map { SkillCount(name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(skillLimit)
            .map { $0 }
    }

    private func topCompanies(from jobs: [JobResponseDTO]) -> [CompanyCount] {
        let grouped = jobs.reduce(into: [String: CompanyAccumulator]()) { acc, job in
            let key = job.companyName?.lowercased() ?? ""
            var entry = acc[key] ?? CompanyAccumulator(
                displayName: job.companyName ?? "",
                count: 0,
                latestLogo: job.companyLogo,
                latestDate: job.publicationDate,
                latestLocation: job.candidateRequiredLocation ?? ""
            )
            entry.count += 1
            if let date = job.publicationDate,
               entry.latestDate == nil || date > (entry.latestDate ?? .distantPast) {
                entry.latestDate = date
                entry.latestLogo = job.companyLogo
                entry.latestLocation = job.candidateRequiredLocation ?? entry.latestLocation
            }
            acc[key] = entry
        }

        return grouped.values
            .map {
                CompanyCount(
                    name: $0.displayName,
                    count: $0.count,
                    logoURL: $0.latestLogo,
                    lastJobDate: $0.latestDate,
                    location: $0.latestLocation.isEmpty ? "Remote" : $0.latestLocation
                )
            }
            .sorted { $0.count > $1.count }
            .prefix(companyLimit)
            .map { $0 }
    }

    /// "software development" → "Software Development"
    private func prettyCase(_ raw: String) -> String {
        raw.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }
}

// MARK: - Accumulator (privado ao módulo)

/// Usado apenas durante a agregação de empresas.
/// Privado ao módulo (não-public) — não vaza pra fora.
private struct CompanyAccumulator {
    let displayName: String
    var count: Int
    var latestLogo: String?
    var latestDate: Date?
    var latestLocation: String
}
