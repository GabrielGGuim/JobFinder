//
//  FlowLayout.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 18/07/26.
//
import SwiftUI

public struct FlowLayout: Layout {
    var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let availableWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var cursorX: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let itemSize = subview.sizeThatFits(.unspecified)

            if cursorX + itemSize.width > availableWidth {
                cursorX = 0
                totalHeight += currentRowHeight + spacing
                currentRowHeight = 0
            }

            cursorX += itemSize.width + spacing
            currentRowHeight = max(currentRowHeight, itemSize.height)
        }

        totalHeight += currentRowHeight
        return CGSize(width: availableWidth, height: totalHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var cursorX: CGFloat = bounds.minX
        var cursorY: CGFloat = bounds.minY
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let itemSize = subview.sizeThatFits(.unspecified)

            if cursorX + itemSize.width > bounds.maxX {
                cursorX = bounds.minX
                cursorY += currentRowHeight + spacing
                currentRowHeight = 0
            }

            subview.place(at: CGPoint(x: cursorX, y: cursorY), proposal: .unspecified)

            cursorX += itemSize.width + spacing
            currentRowHeight = max(currentRowHeight, itemSize.height)
        }
    }
}
