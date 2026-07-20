//
//  CompanyRow.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 20/07/26.
//
import SwiftUI

public protocol CompanyRowRepresentable {
    var name: String { get }
    var location: String { get }
    var lastSeenLabel: String { get }
    var count: Int { get }
    var logoURL: String? { get }
    var initials: String { get }
}

public struct CompanyRow: View {
    let rank: Int
    let company: CompanyRowRepresentable
    
    public init(
        rank: Int,
        company: CompanyRowRepresentable
    ) {
        self.rank = rank
        self.company = company
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .robotoFont(.bold, size: 14, color: .gray)
                .padding(.leading, 8)
            
            logo
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(company.name)
                    .robotoFont(.bold, size: 14)
                    .lineLimit(1)
                Text("\(company.location) • ⏰ \(company.lastSeenLabel)")
                    .robotoFont(.regular, size: 11, color: .gray)
            }
            
            Spacer()
            
            HStack(spacing: 2) {
                Text("\(company.count)")
                    .robotoFont(.bold, size: 14, color: .blue)
                Text("vacancies")
                    .robotoFont(.regular, size: 10, color: .blue)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Color(red: 0.91, green: 0.94, blue: 1.0)
            )
            .clipShape(Capsule())
            
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        .fixedSize(horizontal: false, vertical: true)

    }
    
    @ViewBuilder
    private var logo: some View {
        if let urlString = company.logoURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                default:
                    initialsPlaceholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            initialsPlaceholder
        }
    }
    
    private var initialsPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.91, green: 0.94, blue: 1.0))
            Text(company.initials)
                .robotoFont(.bold, size: 14, color: .blue)
        }
    }
}
