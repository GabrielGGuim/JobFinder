//
//  MarketPulseView.swift
//  MarketPulse
//
//  Created by Gabriel Gonçalves Guimarães on 17/07/26.
//


import SwiftUI
import Components
import ViewModifiers
import NetworkLayer

public struct MarketPulseView: View {
    
    @StateObject private var viewModel: MarketPulseViewModel
    
    public init(viewModel: MarketPulseViewModel = MarketPulseViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    content()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .background(Color("MarketPulseView.Background", bundle: .module))
        }
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Market")
                .robotoFontText(.bold, size: 24, color: .black)
            +
            Text(" Pulse")
                .robotoFontText(.bold, size: 24, color: .blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Content dispatcher
    
    @ViewBuilder
    private func content() -> some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadedContent(data: .skeleton)
                .redacted(reason: .placeholder)
                .animatePlaceholder(isLoading: .constant(true))
                .disabled(true)
        case .loaded(let data):
            LoadedContent(data: data)
        case .error(let message):
            ErrorView(message: message) {
                Task {
                    await viewModel.retry()
                }
            }
        }
    }
}

// MARK: - Loaded content

private struct LoadedContent: View {
    
    let data: MarketPulseData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack {
                Image("MarketPulseView.Card.Background", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                VStack(alignment: .leading) {
                    HStack {
                        PulseDot()
                        Text("Vagas remotas ativas".uppercased())
                            .robotoFont(.bold, size: 12, color: .white)
                            .padding(.bottom, 4)
                    }
                    Text("\(data.totalJobs.formatted(.number))")
                        .robotoFont(.bold, size: 40, color: .white)
                        .padding(.bottom, 8)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            SectionView(title: "Top Categorias") {
                HorizontalCellScroller(
                    items: .constant(data.topCategories),
                    titleClosure: { $0.name },
                    subtitleClosure: { String($0.count) },
                    imageClosure: { $0.name },
                    tapGesture: { item in
                        print(item)
                    },
                    paddingLeading: 4,
                    isSelectedClosure: { _ in false }
                )
            }
            
            SectionView(title: "Skills on the Rise") {
                FlowLayout(spacing: 6) {
                    ForEach(data.topSkills, id: \.self) { tag in
                        TagPill(title: tag.name)
                    }
                }
            }
            
            SectionView(title: "Companies Hiring") {
                VStack(spacing: 8) {
                    ForEach(Array(data.topCompanies.enumerated()), id: \.element.id) { index, company in
                        CompanyRow(rank: index + 1, company: company)
                    }
                }
            }
        }
    }
}

// MARK: - Section header (reusable)

private struct SectionView<Content: View>: View {
    
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .robotoFont(.bold, size: 16)
                Spacer()
            }
            content()
        }
    }
}
