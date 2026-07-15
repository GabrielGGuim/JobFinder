//
//  Action.swift
//  ReduxCore
//
//  Action = "algo que aconteceu" na View.
//  É um enum (ou struct) que descreve a intenção.
//  O Reducer recebe a Action e decide o que muda no State.
//
//  Exemplo numa feature de vagas:
//      enum VacancyListAction {
//          case onAppear                  // "a tela apareceu"
//          case fetchSucceeded([Job])     // "API respondeu OK com N vagas"
//          case fetchFailed(String)       // "API respondeu com erro X"
//      }
//
//  A Action NÃO diz como mudar o State.
//  Ela só carrega a informação. Quem decide é o Reducer.
//

import Foundation

public protocol Action: Sendable {}
