//
//  HorizontalImageScroller.swift
//  spGovBr
//
//  Created by Gabriel Gonçalves Guimarães on 05/07/23.
//

import Foundation
import SwiftUI

public struct HorizontalCellScroller<Item: Hashable>: View {

    @Binding private var items: [Item]
    private let titleClosure: (Item) -> String
    private let subtitleClosure: (Item) -> String
    private let imageClosure: (Item) -> String

    private let tapGesture: (Item) -> Void
    private let horizontalPadding: CGFloat
    let isSelectedClosure: (Item) -> Bool

    public init(
        items: Binding<[Item]>,
        titleClosure: @escaping (Item) -> String,
        subtitleClosure: @escaping (Item) -> String,
        imageClosure: @escaping (Item) -> String,
        tapGesture: @escaping (Item) -> Void,
        paddingLeading: CGFloat = 0,
        isSelectedClosure: @escaping (Item) -> Bool
    ) {
        self._items = items
        self.titleClosure = titleClosure
        self.subtitleClosure = subtitleClosure
        self.imageClosure = imageClosure
        self.tapGesture = tapGesture
        self.horizontalPadding = paddingLeading
        self.isSelectedClosure = isSelectedClosure

    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    cardView(for: item)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }

    @ViewBuilder
    private func cardView(for item: Item) -> some View {
        VStack(alignment: .leading) {
            Text("📎")
                .font(.system(size: 40))
                .padding(.bottom, 8)
            Text(titleClosure(item))
                .robotoFont(.bold, size: 12, color: .black)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 4)
            Text(subtitleClosure(item))
                .robotoFontText(.bold, size: 11, color: .black)
            +
            Text(" jobs")
                .robotoFontText(.regular, size: 11, color: .gray)
        }
        .frame(idealWidth: 140, minHeight: 110, alignment: .leading)
        .padding(13)
        .background(
            Color(
                "HorizontalView.Background",
                bundle: .module
            )
        )
        .cornerRadius(14)

        .onTapGesture {
            tapGesture(item)
        }
    }
}
