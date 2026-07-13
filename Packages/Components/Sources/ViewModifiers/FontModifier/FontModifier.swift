//
//  FontModifier.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 08/07/26.
//

import Foundation
import SwiftUI

public struct RobotoFont: ViewModifier {
    
    public enum RobotoType: String {
        case regular = "Roboto-Regular"
        case medium = "Roboto-Medium"
        case semiBold = "Roboto-SemiBold"
        case bold = "Roboto-Bold"
    }
    
    public enum RobotoColor {
        case black
        case white
        case gray
        case secondGray
        case custom(Color)
        
        public var color: Color {
            switch self {
            case .black:
                return Color("Roboto.Black", bundle: .module)
            case .white:
                return Color("Roboto.White", bundle: .module)
            case .gray:
                return Color("Roboto.Gray", bundle: .module)
            case .secondGray:
                return Color("Roboto.SecondGray", bundle: .module)
            case .custom(let customColor):
                return customColor
            }
        }
    }
    
    let isItalic: Bool
    var type: RobotoType
    var size: CGFloat
    var color: RobotoColor
    
    let baseScreenWidth: CGFloat = 1
    
    public init(_ type: RobotoType, size: CGFloat, isItalic: Bool, color: RobotoColor) {
        self.type = type
        self.size = size
        self.isItalic = isItalic
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        if isItalic {
            content
                .font(
                    .custom(type.rawValue, size: size * baseScreenWidth)
                    .italic()
                )
                .foregroundColor(color.color)
        } else {
            content
                .font(
                    .custom(type.rawValue, size: size * baseScreenWidth)
                )
                .foregroundColor(color.color)
        }
    }
}

extension View {
    public func robotoFont(
        _ type: RobotoFont.RobotoType,
        size: CGFloat,
        isItalic: Bool = false,
        color: RobotoFont.RobotoColor = .black
    ) -> some View {
        modifier(RobotoFont(type, size: size, isItalic: isItalic, color: color))
    }
}

extension Text {
    public func openSansFontText(
        _ fontWeight: RobotoFont.RobotoType,
        size: CGFloat,
        color: RobotoFont.RobotoColor
    ) -> Text {
        self
            .font(.custom(fontWeight.rawValue, size: size))
            .foregroundColor(color.color)
    }
}
