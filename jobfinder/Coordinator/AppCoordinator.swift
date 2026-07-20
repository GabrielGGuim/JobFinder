//
//  AppCoordinator.swift
//  jobfinder
//
//  Coordinator do app.
//
//  O `enum AppCoordinator` funciona como **namespace** — não pode ser instanciado.
//  Dentro dele ficam as **classes** que fazem o trabalho de fato:
//  - `Root`: decide o que mostrar no nível raiz (hoje: TabBar)
//  - `TabBar`: gerencia a tab bar com MarketPulse + VacancyView
//
//  Esse padrão (enum + classes aninhadas) é comum em Swift porque:
//  1. Evita que alguém acidentalmente instancie o "AppCoordinator"
//  2. Agrupa visualmente os tipos relacionados
//  3. Permite acessar como `AppCoordinator.TabBar()` em vez de criar arquivo separado
//

import Foundation

// MARK: - Namespace

/// Enum-namespace. NÃO instanciar — use as classes aninhadas.
enum AppCoordinator {
    
    // MARK: - Coordinator raiz
    //
    // Decide qual a "primeira tela" do app.
    // Hoje é a TabBar; amanhã pode ser uma OnboardingFlow, LoginFlow, etc.
    
    @MainActor
    final class Root: ObservableObject {
        
        let tabBar: TabBar
        
        init(tabBar: TabBar) {
            self.tabBar = tabBar
        }
        
        convenience init() {
            self.init(tabBar: TabBar())
        }
    }
    
    // MARK: - TabBar coordinator
    //
    // Gerencia o estado de qual tab está selecionada.
    // Não sabe nada sobre SwiftUI — só estado e regras de navegação.
    
    @MainActor
    final class TabBar: ObservableObject {
        
        // MARK: - Tabs disponíveis
        //
        // Adicionar uma tab nova? Mexe só aqui. O enum é a fonte de verdade.
        enum Tab: String, CaseIterable, Identifiable {
            case marketPulse
            case vacancy
            
            var id: String { rawValue }
            
            var title: String {
                switch self {
                case .marketPulse: return "Market Pulse"
                case .vacancy:     return "Vacancy"
                }
            }
            
            var systemImage: String {
                switch self {
                case .marketPulse: return "chart.line.uptrend.xyaxis"
                case .vacancy:     return "list.bullet.rectangle"
                }
            }
        }
        
        // MARK: - Estado
        
        /// Tab atualmente selecionada.
        @Published var selected: Tab = .marketPulse
        
        // MARK: - Routing (intents)
        //
        // Cada intent = uma ação que muda o estado do coordinator.
        // Mantém a View burra: ela só chama `coordinator.select(.vacancy)`.
        
        func select(_ tab: Tab) {
            selected = tab
        }
    }
}
