//
//  ErrorView.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 20/07/26.
//

import SwiftUI

public struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.88))
                    .frame(width: 64, height: 64)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.96, green: 0.65, blue: 0.14))
            }

            Text("Erro")
                .robotoFont(.bold, size: 18)

            Text(message)
                .robotoFont(.regular, size: 13, color: .gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            ButtonView(
                typeStyleButton: .backgroundBlue(
                    ButtonView.StyleButton.init(
                        text: "↺ Tentar de novo",
                        tapGesture: { onRetry() })
                )
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
