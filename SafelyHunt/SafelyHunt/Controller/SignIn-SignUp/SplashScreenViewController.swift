//
//  SplashScreenViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        FirebaseManagement.shared.checkUserLogged { userIsLogged in
            switch userIsLogged {
            case .success(_):
                self.transfertToMainStarter()
//                self.goToViewTest()
            case .failure(_):
                self.transfertToLogin()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        FirebaseManagement.shared.removeStateChangeLoggedListen()
    }
    
    private func transfertToMainStarter() {
        let mainStarterStoryboard = UIStoryboard(name: "TabbarMain", bundle: nil)
        
        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {
            return
        }
        
        mainStarterViewController.modalPresentationStyle = .fullScreen
        self.present(mainStarterViewController, animated: true)
    }
    
    private func transfertToLogin() {
    
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }
        
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true)
    }
    
}
