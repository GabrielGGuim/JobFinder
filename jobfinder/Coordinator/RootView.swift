//
//  RootView.swift
//  jobfinder
//
//  Created by Gabriel Gonçalves Guimarães on 20/07/26.
//

import SwiftUI
import VacancyModule
import MarketPulseModule

// MARK: - Root View

struct RootView: View {
    @StateObject var coordinator: AppCoordinator.Root
    
    var body: some View {
        TabBarView(coordinator: coordinator.tabBar)
    }
}

// MARK: - TabBar View

struct TabBarView: View {
    @ObservedObject var coordinator: AppCoordinator.TabBar
    
    var body: some View {
        TabView(selection: $coordinator.selected) {
            ForEach(AppCoordinator.TabBar.Tab.allCases) { tab in
                content(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
    }
    
    // MARK: - View por tab
    
    @ViewBuilder
    private func content(for tab: AppCoordinator.TabBar.Tab) -> some View {
        switch tab {
        case .marketPulse:
            MarketPulseView()
        case .vacancy:
            VacancyView()
        }
    }
}
