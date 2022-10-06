//
//  SplashScreenViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SplashScreenViewController: UIViewController {

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// check if user is sign in or not If user is sign in go to main, if not go to login page
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        UserServices.shared.checkUserLogged { hunter in
            switch hunter {
            case .success(let hunter):
                self.transferToMainStarter(hunter: hunter)
            case .failure(_):
                self.transferToLogin()
            }
        }
    }

    /// remove observer logged user
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        UserServices.shared.removeStateChangeLoggedListen()
    }

    // MARK: - private functions
    /// transfer to main starter controller
    /// - Parameter hunter: hunter logged
    private func transferToMainStarter(hunter: Hunter) {
        let mainStarterStoryboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {
            return
        }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarterViewController, animationOption: .transitionFlipFromBottom)
    }

    /// transfert to LoginView controller
    private func transferToLogin() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController, animationOption: .transitionFlipFromLeft)
    }
}
