//
//  ButtonView.swift
//
//  Created by Gabriel Gonçalves Guimarães
//

import SwiftUI

public struct ButtonView: View {
    let typeStyleButton: TypeStyleButton
    @State private var isPressed: Bool = false
    
    public init(typeStyleButton: TypeStyleButton) {
        self.typeStyleButton = typeStyleButton
    }
    
    public enum TypeStyleButton {
        case backgroundBlue(StyleButton)
    }
    
    public struct StyleButton {
        let text: String
        var textForegroundColor: String?
        var backgroud: String?
        var imageName: String?
        var tapGesture: () -> Void
        var alignment: Alignment = .center
        @Binding var disable: Bool
        
        public init(
            text: String,
            textForegroundColor: String? = nil,
            backgroud: String? = nil,
            imageName: String? = nil,
            tapGesture: @escaping () -> Void,
            alignment: Alignment = .center,
            disable: Binding<Bool> = .constant(false)
        ) {
            
            self.text = text
            self.textForegroundColor = textForegroundColor
            self.backgroud = backgroud
            self.imageName = imageName
            self.tapGesture = tapGesture
            self.alignment = alignment
            self._disable = disable
        }
    }
    
    public var body: some View {
        switch typeStyleButton {
        case .backgroundBlue(let styleButton):
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    styleButton.tapGesture()
                })
            } label: {
                ZStack {
                    HStack(alignment: .center, spacing: 10) {
                        if let image = styleButton.imageName {
                            Image(image, bundle: .module)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                        }
                        Text(styleButton.text)
                            .robotoFont(.bold, size: 16, color: .white)
                    }
                }
            }
            .buttonStyle(CustomFilledButtonStyle(colorType: .blue, styleButton: styleButton))
            .disabled(styleButton.disable)
        }
    }
    
}

struct CustomFilledButtonStyle: ButtonStyle {
    
    enum ColorType {
        case blue, white
    }
    
    let colorType: ColorType
    let styleButton: ButtonView.StyleButton
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: styleButton.alignment == .center ? .infinity : nil)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                Color("buttonView.button.filled.background", bundle: Bundle.module)
            )
            .clipShape(Capsule())
            .overlay(
                ZStack {
                    if colorType == .blue {
                        Capsule()
                            .stroke(
                                configuration.isPressed
                                ? Color("buttonView.button.filled.background", bundle: Bundle.module).opacity(0.2)
                                : .clear,
                                lineWidth: 8
                            )
                            .padding(-1.5)
                    }
                }
            )
            .frame(maxWidth: .infinity, alignment: styleButton.alignment)
            .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)
    }
}
