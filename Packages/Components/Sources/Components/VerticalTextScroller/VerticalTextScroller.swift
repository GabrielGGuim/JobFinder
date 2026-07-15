//
//  VerticalImageScroller.swift
//  spGovBr
//
//  Created by Gabriel Gonçalves Guimarães on 05/07/23.
//

import Foundation
import SwiftUI

public struct VerticalImageScroller<Item: Hashable>: View {
    
    @Binding private var items: [Item]
    private let titleClosure: (Item) -> String
    private let subtitleClosure: (Item) -> String
    private let localClosure: (Item) -> String
    private let timeClosure: (Item) -> String
    private let tagClosure: (Item) -> [String]
    
    private let tapGesture: (Item) -> Void
    private let horizontalPadding: CGFloat
    
    public init(
        items: Binding<[Item]>,
        titleClosure: @escaping (Item) -> String,
        subtitleClosure: @escaping (Item) -> String,
        localClosure: @escaping (Item) -> String,
        timeClosure: @escaping (Item) -> String,
        tagClosure: @escaping (Item) -> [String],
        tapGesture: @escaping (Item) -> Void,
        paddingLeading: CGFloat = 0
    ) {
        self._items = items
        self.titleClosure = titleClosure
        self.subtitleClosure = subtitleClosure
        self.localClosure = localClosure
        self.timeClosure = timeClosure
        self.tagClosure = tagClosure
        self.tapGesture = tapGesture
        self.horizontalPadding = paddingLeading
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    cardView(for: item, index: index)
                        .padding(16)
                        .background(Color("VerticalView.Background.Card", bundle: .module))
                        .cornerRadius(12)
                        .onTapGesture {
                            tapGesture(item)
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardView(for item: Item, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(String(subtitleClosure(item).prefix(1)).uppercased())
                    .robotoFont(.bold, size: 16, color: .white)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(RandomGradient.random())
                    )
                
                VStack(alignment: .leading) {
                    Text(titleClosure(item))
                        .robotoFont(.bold, size: 15)
                    Text(subtitleClosure(item))
                        .robotoFont(.regular, size: 13)
                }
            }
            HStack(spacing: 12) {
                Group {
                    Text("📍 \(localClosure(item))")
                    Text("⏱️ \(timeClosure(item))")
                }
                .robotoFont(.regular, size: 12, color: .secondGray)
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(tagClosure(item), id: \.self) { item in
                        Text(item)
                            .robotoFont(.regular, size: 11)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(Color("VerticalView.Background", bundle: .module))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}
