//
//  AccountSettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 02/09/2022.
//

import UIKit

class AccountSettingsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var disconnectedButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var activyIndicator: UIActivityIndicatorView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButton()
    }

    // MARK: - IBAction
    @IBAction func disconnectButtonAction() {
        disconnectedButton.isHidden = true
        activyIndicator.isHidden = false
        resetUserDefault()
       disconnectUserInApplication()
    }

    @IBAction func deleteAccountButtonAction() {
        presentConfirmPassword()
    }

    // MARK: - Private functions
    /// set up ui button
    private func setUpButton() {
        disconnectedButton.layer.cornerRadius = disconnectedButton.frame.height/2
        deleteAccountButton.layer.cornerRadius = deleteAccountButton.frame.height/2
    }

    /// Disconnected user in application
    private func disconnectUserInApplication() {
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

    /// Show popup for confirm action before deleted action
    private func presentConfirmPassword() {
        let alertViewController = UIAlertController(
            title: "Confirm action".localized(tableName: "LocalizableAccountSetting"),
            message: "Enter your password for confirm action".localized(tableName: "LocalizableAccountSetting"),
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "Cancel".localized(tableName: "Localizable"), style: .cancel, handler: nil)
        alertViewController.addTextField() { textfield in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "password...".localized(tableName: "LocalizableAccountSetting")
        }
        let confirmAction = UIAlertAction(title: "Confirm".localized(tableName: "LocalizableAccountSetting"), style: .destructive) { _ in
            guard let textfield = alertViewController.textFields?[0],
                    let password = textfield.text,
                    !password.isEmpty else {
                self.presentAlertError(alertMessage: "Enter your password".localized(tableName: "LocalizableAccountSetting"))
                return
            }
            self.deleteAccount(password: password)
        }
        alertViewController.addAction(confirmAction)
        alertViewController.addAction(cancel)

        present(alertViewController, animated: true, completion: nil)
    }

    /// Delete account from firebase database
    /// - Parameter password: transfer password for credential
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

    /// Transfer to LoginController after action
    private func navigationToLoginViewController() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {return}

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController, animationOption: .transitionCrossDissolve)
    }

    /// reset UserDefault after action
    private func resetUserDefault() {
        let userDefault = UserDefaults.standard
        userDefault.set("", forKey: UserDefaultKeys.Keys.areaSelected)
        userDefault.set(true, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        userDefault.set(300, forKey: UserDefaultKeys.Keys.radiusAlert)
        userDefault.set(0, forKey: UserDefaultKeys.Keys.mapTypeSelected)
        userDefault.set(true, forKey: UserDefaultKeys.Keys.showInfoRadius)
        userDefault.set(false, forKey: UserDefaultKeys.Keys.tutorialHasBeenSeen)
    }
}
