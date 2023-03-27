//
//  URLStorageApp.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import GoogleMobileAds

@main
struct URLStorageApp: App {
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class MyAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

class MySceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var windowScene: UIWindowScene?
    var window: UIWindow? {
        windowScene?.keyWindow
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        windowScene = scene as? UIWindowScene
    }
}

extension MyAppDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = MySceneDelegate.self
        }
        return configuration
    }
}
