//
//  jobfinder
//
//  Created by Gabriel Gonçalves Guimarães on 08/07/26.
//

import SwiftUI
import Components
import VacancyModule
import ViewModifiers
import NetworkLayer
import FirebaseData
import FirebaseCore
import Settings

@main
struct JobFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        Config.environment = .homolog
        NetworkLayer.shared.showLog = true
        FontsRegister.registerFonts()
    }
    var body: some Scene {
        WindowGroup {
            VacancyView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var window: UIWindow?
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure(options: configInfo())
        return true
    }
    private func configInfo() -> FirebaseOptions {
        guard
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let fileopts = FirebaseOptions(contentsOfFile: filePath)
        else {
            assert(false, "Couldn't load Firebase config file")
            fatalError("Couldn't load Firebase config file")
        }
        return fileopts
    }
}
