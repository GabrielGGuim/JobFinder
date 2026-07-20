//
//  PulseDot.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 18/07/26.
//
import SwiftUI

public struct PulseDot: View {

    @State private var animate = false
    
    public init(animate: Bool = false) {
        self.animate = animate
    }

    public var body: some View {
        Circle()
            .fill(Color(red: 0.12, green: 0.71, blue: 0.49))
            .frame(width: 8, height: 8)
            .scaleEffect(animate ? 1.2 : 1.0)
            .animation(
                .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear { animate = true }
    }
}
