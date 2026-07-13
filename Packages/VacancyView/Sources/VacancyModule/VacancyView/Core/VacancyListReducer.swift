//
//  JobDTO.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 10/07/26.
//

//
//  VacancyListReducer.swift
//  VacancyModule
//
//  Reducer = função PURA. (State, Action) -> State novo.
//
//  ⚠️ NUNCA chame API, Banco, Date(), print, random aqui dentro.
//     Só switch + return de um state novo.
//

import Foundation
import ReduxCore
import SwiftUI

public func vacancyListReducer(
    _ state: VacancyListState,
    _ action: VacancyListAction
) -> VacancyListState {
    switch action {
        
    case .onAppear:
        var state = state
        state.loading = true
        state.error = nil
        return state
        
    case .fetchSucceeded(let response):
        var state = state
        state.loading = false
        state.jobs.append(contentsOf: response.data)
        return state
        
    case .fetchFailed(let message):
        var state = state
        state.loading = false
        state.error = message
        return state
    case .selectTag(let tag):
        var state = state
        state.selectedTag = tag
        return state
    case .search(let text):
        var state = state
        state.searchText = text
        return state
    case .pushJob(let job):
        var state = state
        state.routes.append(.jobDetail(job))
        return state
        
    case .popRoute:
        var state = state
        guard !state.routes.isEmpty else { return state }
        state.routes.removeLast()
        return state
        
    case .popToRoot:
        var state = state
        state.routes.removeAll()
        return state
        
    case .setRoutes(let routes):
        var state = state
        state.routes = routes
        return state
    }
}
