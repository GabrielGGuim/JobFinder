//
//  CustomNavigationBar.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 11/07/26.
//


import SwiftUI

public struct CustomNavigationBar: ViewModifier {
    var nameNavigation: String
    @Environment(\.presentationMode) private var presentationMode
    var colorBackgroud: Color
    public func body(content: Content) -> some View {
        ZStack {
            content
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        leadingView()
                    }
                }
                .padding(.top, 8)
                .swipeBackGesture(enabled: true)
                .background(colorBackgroud)
        }
    }
    
    private func leadingView() -> some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            },
            label: { backView() }
        )
    }
    @ViewBuilder
    private func backView() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 5) {
                Image("backButton", bundle: .module)
                    .scaledToFit()
                    .foregroundColor(.white)
                Text(nameNavigation)
                    .robotoFont(.bold, size: 16)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }
    }
}

extension View {
    @ViewBuilder
    public func customNavigationBar(
        nameNavigation: String,
        colorBackgroud: Color? = nil
    ) -> some View {

        let background = colorBackgroud
            ?? Color("CustomNavigation.Background", bundle: .module)

        modifier(
            CustomNavigationBar(
                nameNavigation: nameNavigation,
                colorBackgroud: background
            )
        )
    }
}
struct NavigationBarModifier_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Text("First view")
                NavigationLink {
                    Text("Second view")
                        .customNavigationBar(nameNavigation: "")
                } label: {
                    Text("Second view")
                }
            }
            .customNavigationBar(nameNavigation: "")
        }
    }
}

struct SwipeBackGesture: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                SwipeBackView(isEnabled: isEnabled)
            )
    }
}

struct SwipeBackView: UIViewControllerRepresentable {
    let isEnabled: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        SwipeBackViewController(isEnabled: isEnabled)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let swipeVC = uiViewController as? SwipeBackViewController {
            swipeVC.updateGesture(enabled: isEnabled)
        }
    }
}

class SwipeBackViewController: UIViewController {
    private var isEnabled: Bool
    
    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGesture(enabled: isEnabled)
    }
    
    func updateGesture(enabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = enabled
        navigationController?.interactivePopGestureRecognizer?.delegate = enabled ? self : nil
    }
}

extension SwipeBackViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

extension View {
    func swipeBackGesture(enabled: Bool) -> some View {
        modifier(SwipeBackGesture(isEnabled: enabled))
    }
}
