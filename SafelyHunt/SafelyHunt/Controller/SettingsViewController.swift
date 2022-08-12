//
//  SettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func disconnectButton() {
        resetUserDefault()
        FirebaseManagement.shared.disconnectCurrentUser()
            transferToLogin()
    }


    private func transferToLogin() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }

        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true)
    }

    private func resetUserDefault() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: UserDefaultKeys.Keys.areaSelected)
        userDefault.set(true, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        userDefault.set(0,forKey: UserDefaultKeys.Keys.radiusAlert)
    }
}
