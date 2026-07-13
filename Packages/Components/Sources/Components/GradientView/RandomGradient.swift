//
//  RandomGradient.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//

import SwiftUI

public enum RandomGradient {

    private static let gradients: [[Color]] = [
        [.purple, .indigo],
        [.green, .teal],
        [.pink, .red],
        [.orange, .yellow],
        [.blue, .cyan],
        [.mint, .cyan],
        [.indigo, .blue],
        [.brown, .orange],
        [.purple, .pink],
        [.teal, .green]
    ]

    public static func random() -> LinearGradient {
        let colors = gradients.randomElement()!

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public static func gradient(for index: Int) -> LinearGradient {
        let colors = gradients[index % gradients.count]

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
