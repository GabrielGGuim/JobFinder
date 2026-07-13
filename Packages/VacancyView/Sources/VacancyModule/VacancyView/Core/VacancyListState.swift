//
//  JobDTO.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 10/07/26.
//

//
//  VacancyListState.swift
//  VacancyModule
//
//  State = "a foto" atual da tela. Tudo que a VacancyView
//  precisa pra se renderizar mora aqui dentro.
//
//  Sempre que uma Action é disparada, o Reducer devolve um
//  State NOVO. Nunca se muta o state em cima.
//

import Foundation
import ReduxCore

public struct VacancyListState: State {

    /// Lista de vagas carregada da API.
    public var jobs: [JobDTO] = []

    /// Se tá carregando a próxima página.
    public var loading: Bool = false

    /// Mensagem de erro, se algo deu errado.
    public var error: String? = nil
    
    public var selectedTag: String = "All"
    public var searchText: String = ""

    /// Pilha de navegação como tipo próprio, não NavigationPath.
    public var routes: [VacancyRoute] = []

    public init() {}
}

public extension VacancyListState {
    var filteredJobs: [JobDTO] {
        var result = jobs

        if selectedTag != "All" {
            result = result.filter { $0.tags.contains(selectedTag) }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.companyName.lowercased().contains(query)
            }
        }

        return result
    }

    var allTags: [String] {
        ["All"] + Array(Set(jobs.flatMap(\.tags))).sorted()
    }
}
