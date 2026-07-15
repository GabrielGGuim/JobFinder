//
//  AnimatePlaceholderModifier.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 12/07/26.
//


import SwiftUI

public struct AnimatePlaceholderModifier: AnimatableModifier {
    @Binding var isLoading: Bool
    
    @State private var startPoint: UnitPoint = .init(x: -1.8, y: -1.2)
    @State private var endPoint: UnitPoint = .init(x: 0, y: -0.2)
    
    public init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }

    public func body(content: Content) -> some View {
        content.overlay(animView.mask(content))
    }
    
    public var animView: some View {
        Color.white.opacity(0.5)
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.clear, .white, .clear], startPoint: startPoint, endPoint: endPoint)
                    )
            )
            .opacity(isLoading ? 1 : 0)
            .onAppear {
                guard isLoading else { return }
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                    startPoint = .init(x: 1, y: 1)
                    endPoint = .init(x: 2.2, y: 2.2)
                }
            }
    }
}

extension View {
    public func animatePlaceholder(isLoading: Binding<Bool>) -> some View {
        self.modifier(AnimatePlaceholderModifier(isLoading: isLoading))
    }
}

#Preview(body: {
    Color.black
        .animatePlaceholder(isLoading: .constant(true))
})
