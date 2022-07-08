//
//  SplashScreenViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SplashScreenViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if FirebaseManagement.shared.checkUserLogged() {
            transfertToMainStarter()
        } else {
            transfertToLogin()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        FirebaseManagement.shared.removeStateChangeLoggedListen()

    }
    
    private func transfertToMainStarter() {
        let mainStarterStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "MainStarter") as? MainStarterViewController else {
            return
        }
        
        mainStarterViewController.modalPresentationStyle = .fullScreen
        self.tabBarController?.setViewControllers([mainStarterViewController], animated: true)
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
