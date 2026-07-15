//
//  VacancyDetailView.swift
//  VacancyView
//
//  Created by Gabriel Gonçalves Guimarães on 09/07/26.
//

import SwiftUI
import Components
import ViewModifiers
import FirebaseData

public struct VacancyView: View {

    @StateObject private var store: VacancyListStore = .make()

    public init() {}

    public var body: some View {
        NavigationStack(path: pathBinding) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    if !store.state.jobs.isEmpty {
                        tagScroller
                    }
                    content()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
            .background(Color("VacancyView.Background", bundle: .module))
            .navigationDestination(for: VacancyRoute.self) { route in
                switch route {
                case .jobDetail(let job):
                    VacancyDetailView(job: job)
                        .customNavigationBar(nameNavigation: "Vacancies")
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var pathBinding: Binding<[VacancyRoute]> {
        Binding(
            get: { store.state.routes },
            set: { newRoutes in store.send(.setRoutes(newRoutes)) }
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("International Vacancies")
                .robotoFont(.bold, size: 28)
            SearchBar(text: Binding(
                get: { store.state.searchText },
                set: { store.send(.search($0)) }
            ), keyboardActive: {
                Task {
                    await FirebaseConfig.shared.save(VacancyViewFirebase.tapSearch)
                }
            })
        }
    }

    private var tagScroller: some View {
        HorizontalTextScroller(
            items: .constant(store.state.allTags),
            textClosure: { $0 },
            tapGesture: { tag in
                Task {
                    await FirebaseConfig.shared.save(VacancyViewFirebase.tapFilter)
                    store.send(.selectTag(tag))
                }
            },
            paddingLeading: 16,
            isSelectedClosure: { $0 == store.state.selectedTag }
        )
        .padding(.horizontal, -16)
    }

    // MARK: - Content dispatcher

    /// Decide o que renderizar baseado no estado do store.
    /// Ordem de prioridade: erro → loading (skeleton) → vazio → lista.
    @ViewBuilder
    private func content() -> some View {
        if let error = store.state.error {
            errorView(message: error)
        } else if !store.state.loading && store.state.jobs.isEmpty {
            VStack {
                Spacer()
                Text("No Vacancy")
                    .robotoFont(.bold, size: 28)
                Spacer()
            }
        } else {
            jobsListView
        }
    }
    
    private var displayedJobs: [JobDTO] {
        if store.state.loading && store.state.jobs.isEmpty {
            return JobDTO.placeholders(count: 6)
        }

        return store.state.filteredJobs
    }

    private var jobsListView: some View {
        VerticalImageScroller(
            items: .constant(displayedJobs),
            titleClosure: { $0.title },
            subtitleClosure: { $0.companyName },
            localClosure: { $0.displayLocation },
            timeClosure: { $0.relativeTime },
            tagClosure: { $0.tags },
            tapGesture: { job in
                guard !store.state.loading else { return }
                Task {
                    await FirebaseConfig.shared.save(VacancyViewFirebase.tapJob)
                    store.send(.pushJob(job))
                }
            }
        )
        .redacted(reason: store.state.loading && store.state.jobs.isEmpty ? .placeholder : [])
        .animatePlaceholder(isLoading: .constant(store.state.loading && store.state.jobs.isEmpty))
        .disabled(store.state.loading && store.state.jobs.isEmpty)
    }

    // MARK: - Error / Empty

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("⚠️").font(.system(size: 36))
            Text("Deu ruim").robotoFont(.bold, size: 16)
            Text(message)
                .robotoFont(.regular, size: 13, color: .gray)
                .multilineTextAlignment(.center)
            Button("Tentar de novo") {
                store.send(.onAppear)
            }
            .robotoFont(.medium, size: 14)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func emptyView() -> some View {
        VStack(spacing: 8) {
            Text("Nenhuma vaga encontrada")
                .robotoFont(.medium, size: 16)
            Text("Tente atualizar puxando pra baixo.")
                .robotoFont(.regular, size: 13, color: .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
