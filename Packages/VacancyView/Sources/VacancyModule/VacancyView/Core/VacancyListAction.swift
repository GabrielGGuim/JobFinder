//  JobDTO.swift
//  VacancyModule
//
//  Created by Gabriel Gonçalves Guimarães on 10/07/26.
//

//
//  VacancyListAction.swift
//  VacancyModule
//
//  Action = intenção/intenção. A View dispara uma action, e
//  o sistema (reducer + middleware) decide o que fazer.
//
//  A action NÃO diz "como" mudar o state, só "o que aconteceu".
//

import Foundation
import ReduxCore
import SwiftUI

public enum VacancyListAction: Action {
    case onAppear
    
    case fetchSucceeded(VacanciesResponseDTO)
    
    case fetchFailed(String)
    
    case selectTag(String)
    case search(String)

    case pushJob(JobDTO)
    case popRoute
    case popToRoot

    case setRoutes([VacancyRoute])
}
