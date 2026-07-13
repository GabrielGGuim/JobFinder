//
//  Reducer.swift
//  ReduxCore
//
//  Reducer = função PURA. Recebe (state, action) e devolve um state novo.
//  Sem side-effect, sem chamada de API, sem Date(), sem nada.
//
//  Exemplo:
//      func vacancyListReducer(
//          _ state: VacancyListState,
//          _ action: VacancyListAction
//      ) -> VacancyListState {
//          switch action {
//          case .onAppear:
//              return state
//          case .fetchSucceeded(let jobs):
//              var s = state
//              s.loading = false
//              s.jobs = jobs
//              return s
//          case .fetchFailed(let message):
//              var s = state
//              s.loading = false
//              s.error = message
//              return s
//          }
//      }
//
//  A grande sacada: como o Reducer é função pura, ele é FÁCIL
//  de testar (input → output) e FÁCIL de raciocinar.
//
//  ---------------------------------------------------------------
//  combineReducers: junta vários reducers num só. Igual ao JS.
//  ---------------------------------------------------------------
//  Como cada View/feature tem seu State, às vezes o State tem
//  "sub-partes" (slices) - ex: dados de vagas + dados de filtros.
//  Em vez de um reducer gigante, você escreve um reducer pra cada
//  slice e usa combineReducers pra juntá-los.
//

import Foundation

public typealias Reducer<State, Action> = (State, Action) -> State
