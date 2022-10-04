//
//  AccountSettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 02/09/2022.
//

import UIKit

class AccountSettingsViewController: UIViewController {
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var activyIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func disconnectButtonAction() {
        resetUserDefault()
        disconnectedButton.isHidden = true
        activyIndicator.isHidden = false
        UserServices.shared.disconnectCurrentUser { [weak self] result in
            switch result {
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.disconnectedButton.isHidden = false
                self?.activyIndicator.isHidden = true
            case .success(let messageDisconnected):
                self?.presentNativeAlertSuccess(alertMessage: messageDisconnected)
                self?.navigationToLoginViewController()
            }
        }
    }

    @IBAction func deleteAccountButtonAction() {
        presentConfirmPassword()
    }

    private func presentConfirmPassword() {
        let alertVC = UIAlertController(title: "Confirm password", message: "Enter your password for confirm action", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addTextField() { textfield in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "password.."
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            guard let textfield = alertVC.textFields?[0], let password = textfield.text, !password.isEmpty else {
                self.presentAlertError(alertMessage: "Enter your password")
                return
            }
            self.deleteAccount(password: password)
        }
        alertVC.addAction(confirmAction)
        alertVC.addAction(cancel)

        present(alertVC, animated: true, completion: nil)
    }

    private func deleteAccount(password: String) {
        deleteAccountButton.isHidden = true
        activyIndicator.isHidden = false
        UserServices.shared.deleteAccount(password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.deleteAccountButton.isHidden = false
                self?.activyIndicator.isHidden = true

            case .success(let stringSuccess):
                self?.resetUserDefault()
                self?.presentNativeAlertSuccess(alertMessage: stringSuccess)
                self?.navigationToLoginViewController()
            }
        }
    }

    private func navigationToLoginViewController() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController, animationOption: .transitionCrossDissolve)
    }

    private func resetUserDefault() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: UserDefaultKeys.Keys.areaSelected)
        userDefault.set(true, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        userDefault.set(300, forKey: UserDefaultKeys.Keys.radiusAlert)
        userDefault.set(0, forKey: UserDefaultKeys.Keys.mapTypeSelected)
    }
}
