//
//  SearchView.swift
//  jobfinder

//
//  Created by Gabriel Gonçalves Guimarães on 08/07/26.
//

import SwiftUI
import ViewModifiers

public struct SearchBar: View {
    @Binding var text: String
    var keyboardActive: () -> Void = {}
    var hint: String?
    
    public init(text: Binding<String>, keyboardActive: @escaping () -> Void = {}, hint: String? = nil) {
        self._text = text
        self.keyboardActive = keyboardActive
        self.hint = hint
    }
    
    public var body: some View {
        HStack {
            HStack(spacing: 7.8) {
                Text("🔍")
                    .onTapGesture {
                        keyboardActive()
                    }
                TextField(hint ?? "Search for vacancies, companies...", text: $text)
                    .robotoFont(.regular, size: 14, color: .gray)
                    .submitLabel(.done)
                    .onSubmit {
                        
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color("SearchView.Shape.Background", bundle: Bundle.module))
            .cornerRadius(8)
        }
    }
}
