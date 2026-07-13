//
//  Store.swift
//  ReduxCore
//
//  Store = o "cérebro" do Redux. É a classe que:
//      1) guarda o State atual
//      2) tem o método `send(_:)` que dispara uma Action
//      3) roda o Reducer (puro) pra produzir o State novo
//      4) opcionalmente roda um Middleware (efeito colateral) que pode
//         devolver uma NOVA Action (ex: "API respondeu, atualiza a lista")
//
//  A Store é um ObservableObject - por isso a SwiftUI
//  reage automaticamente quando `state` muda (@Published).
//
//  ------------------------------------------------------------------
//  Fluxo do `send(_:)`:
//      View dispara `.onAppear`
//          → Reducer roda (pode não mudar nada)
//          → Middleware roda async (faz a chamada HTTP)
//          → Middleware devolve `.fetchSucceeded(jobs)` ou `.fetchFailed(msg)`
//          → `send(_:)` é chamado de novo com essa action nova
//          → Reducer roda de novo, agora sim atualizando o state
//  ------------------------------------------------------------------
//

import Foundation
import Combine

@MainActor
public final class Store<State: Sendable, Action: Sendable>: ObservableObject {
    @Published public private(set) var state: State

    private let reducer: Reducer<State, Action>
    private let middleware: (@Sendable (State, Action) async -> Action?)?

    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action>,
        middleware: (@Sendable (State, Action) async -> Action?)? = nil
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middleware = middleware
    }

    public func send(_ action: Action) {
        state = reducer(state, action)

        guard let middleware else { return }
        Task { @MainActor in
            if let nextAction = await middleware(state, action) {
                send(nextAction)
            }
        }
    }
}
