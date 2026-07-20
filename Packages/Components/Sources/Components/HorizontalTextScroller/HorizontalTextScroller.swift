//
//  HorizontalImageScroller.swift
//  spGovBr
//
//  Created by Gabriel Gonçalves Guimarães on 05/07/23.
//

import Foundation
import SwiftUI

public struct HorizontalTextScroller<Item: Hashable>: View {

    @Binding private var items: [Item]
    private let textClosure: (Item) -> String
    private let tapGesture: (Item) -> Void
    private let horizontalPadding: CGFloat
    let isSelectedClosure: (Item) -> Bool

    public init(
        items: Binding<[Item]>,
        textClosure: @escaping (Item) -> String,
        tapGesture: @escaping (Item) -> Void,
        paddingLeading: CGFloat = 0,
        isSelectedClosure: @escaping (Item) -> Bool
    ) {
        self._items = items
        self.textClosure = textClosure
        self.tapGesture = tapGesture
        self.horizontalPadding = paddingLeading
        self.isSelectedClosure = isSelectedClosure

    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    cardView(for: item)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    @ViewBuilder
    private func cardView(for item: Item) -> some View {
        Text(textClosure(item))
            .robotoFont(.medium, size: 13, color: isSelectedClosure(item) ? .white : .black)
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(
                isSelectedClosure(item) ? Color(
                    "HorizontalView.Background.Selected",
                    bundle: .module
                ) : Color(
                    "HorizontalView.Background",
                    bundle: .module
                )
            )
            .clipShape(Capsule())
            .contentShape(Capsule())
            .onTapGesture {
                tapGesture(item)
            }
    }
}
