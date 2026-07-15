//
//  DetectScrollView.swift
//
//  Created by Gabriel Gonçalves Guimarães
//

import Foundation
import SwiftUI

private struct HeightPreferenceKey: PreferenceKey {

    static let defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Adaptive ScrollView

public struct AdaptiveScrollView<Content: View>: View {

    @State private var contentHeight: CGFloat = .zero

    private let showsIndicators: Bool
    private let content: Content

    public init(
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in

            let availableHeight = proxy.size.height

            Group {
                if contentHeight > availableHeight {
                    ScrollView(.vertical, showsIndicators: showsIndicators) {
                        measuredContent
                    }
                } else {
                    measuredContent
                }
            }
        }
    }

    private var measuredContent: some View {
        content
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: HeightPreferenceKey.self,
                        value: proxy.size.height
                    )
                }
            }
            .onPreferenceChange(HeightPreferenceKey.self) { value in
                Task { @MainActor in
                        contentHeight = value
                    }
            }
    }
}
