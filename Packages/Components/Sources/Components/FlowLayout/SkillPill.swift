//
//  SkillPill.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 18/07/26.
//

import SwiftUI

public struct TagPill: View {
    let title: String
    private let dotColor: Color

    private static let colorPalette: [Color] = [
        .blue, .purple, .green, .orange, .pink, .red, .teal, .indigo
    ]

    public init(title: String) {
        self.title = title
        self.dotColor = Self.colorPalette.randomElement() ?? .blue
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            Text(title.capitalized)
                .robotoFont(.bold, size: 12)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
