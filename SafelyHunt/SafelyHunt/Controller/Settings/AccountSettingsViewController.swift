//
//  AccountSettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 02/09/2022.
//

import UIKit

class AccountSettingsViewController: UIViewController {
    @IBOutlet weak var reAuthenticateUiView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var validateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        reAuthenticateUiView.isHidden = true
        showActivityIndicator(shown: false)
    }

    @IBAction func disconnectButton() {
        resetUserDefault()
        UserServices.shared.disconnectCurrentUser { result in
            switch result {
            case .failure(let error):
                self.presentAlertError(alertMessage: error.localizedDescription)
            case .success(let messageDisconnected):
                self.presentNativeAlertSuccess(alertMessage: messageDisconnected)
            }
        }
        self.dismiss(animated: true)
    }
    @IBAction func deleteAccountButton() {
        reAuthenticateUiView.isHidden = false
    }

    @IBAction func validateDeleteAccount() {
        guard let password = passwordTextField.text, !password.isEmpty else {
            presentAlertError(alertMessage: "Enter password")
            return
        }
        showActivityIndicator(shown: true)

        UserServices.shared.deleteAccount(password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.passwordTextField.resignFirstResponder()
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.showActivityIndicator(shown: false)

            case .success(let stringSuccess):
                self?.presentNativeAlertSuccess(alertMessage: stringSuccess)
                self?.dismiss(animated: true)
            }
        }
    }

    @IBAction func cancelButtonAction() {
        reAuthenticateUiView.isHidden = true
        passwordTextField.resignFirstResponder()
    }

    private func showActivityIndicator(shown: Bool) {
        activityIndicator.isHidden = !shown
        validateButton.isHidden = shown

    }

    private func resetUserDefault() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: UserDefaultKeys.Keys.areaSelected)
        userDefault.set(true, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        userDefault.set(300, forKey: UserDefaultKeys.Keys.radiusAlert)
    }
}
