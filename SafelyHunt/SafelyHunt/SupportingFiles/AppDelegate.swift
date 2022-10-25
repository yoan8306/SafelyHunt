//
//  AppDelegate.swift
//  SafelyHunt
//
//  Created by Yoan on 28/06/2022.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // configure firebase launching application
        FirebaseApp.configure()
        // set value for the first launch application
        UserDefaults.standard.register(defaults: [
            UserDefaultKeys.Keys.allowsNotificationRadiusAlert: true,
            UserDefaultKeys.Keys.showInfoRadius: true,
            UserDefaultKeys.Keys.tutorialHasBeenSeen: false,
            UserDefaultKeys.Keys.radiusAlert: 300,
            UserDefaultKeys.Keys.areaSelected: "",
            UserDefaultKeys.Keys.notificationSoundName: "Orchestral-emergency"
        ])
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
