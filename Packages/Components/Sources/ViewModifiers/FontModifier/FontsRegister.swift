//
//  FontsRegister.swift
//
//
//  Created by Mateus Rodrigues on 03/09/24.
//

import Foundation
import SwiftUI

public struct FontsRegister {
    
    enum RobotoTypeFonts: String, CaseIterable {
        case robotoBold = "Roboto-Bold"
        case robotoMedium = "Roboto-Medium"
        case robotoRegular = "Roboto-Regular"
        case robotoSemiBold = "Roboto-SemiBold"
    }
    
    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        bundle.url(forResource: fontName, withExtension: fontExtension)
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't create font from filename: \(fontName) with extension \(fontExtension)")
        }
        CTFontManagerRegisterFontURLs([fontURL] as CFArray, .process, true) { (_, _) -> Bool in
            return true
        }
    }
    
    public static func registerFonts() {
        RobotoTypeFonts.allCases.forEach {
            registerFont(bundle: .module, fontName: $0.rawValue, fontExtension: "ttf")
        }
    }
}
