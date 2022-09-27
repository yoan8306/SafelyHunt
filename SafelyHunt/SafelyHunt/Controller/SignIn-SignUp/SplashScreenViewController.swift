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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        UserServices.shared.removeStateChangeLoggedListen()
    }

// MARK: - private functions
    private func transferToMainStarter(hunter: Hunter) {
        let mainStarterStoryboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {
            return
        }

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarterViewController, animationOption: .transitionFlipFromBottom)
    }

    private func transferToLogin() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController, animationOption: .transitionFlipFromLeft)
    }
}
