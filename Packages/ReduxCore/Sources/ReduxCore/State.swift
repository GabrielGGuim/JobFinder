
//
//  State.swift
//  ReduxCore
//
//  State = "a foto" de tudo que a View precisa pra se renderizar.
//  É um struct imutável. Cada vez que uma Action é disparada,
//  o Reducer devolve um State NOVO (o antigo é descartado).
//
//  Exemplo:
//      struct VacancyListState {
//          var jobs: [Job]            // lista de vagas
//          var loading: Bool          // se tá carregando
//          var error: String?         // mensagem de erro, se tiver
//      }
//
//  State nunca é mutado direto. Só trocado por um novo inteiro.
//

import Foundation

public protocol State: Sendable {}
