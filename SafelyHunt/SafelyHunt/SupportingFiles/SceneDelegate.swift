//
//  SceneDelegate.swift
//  SafelyHunt
//
//  Created by Yoan on 28/06/2022.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    weak var handle: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        // Do any additional setup after loading the view.
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    /// Change viewController for specific viewcontroller
    /// - Parameters:
    ///   - vc: ViewController
    ///   - animated: if transition is animated or not
    ///   - animationOption: select animation option
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true, animationOption: UIView.AnimationOptions) {
        guard let window = window else {
            return
        }
        window.rootViewController = vc

        UIView.transition(with: window,
                          duration: 0.5,
                          options: [animationOption],
                          animations: nil,
                          completion: nil)
    }
}
