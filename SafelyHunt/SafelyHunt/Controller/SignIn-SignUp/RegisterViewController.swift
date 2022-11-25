//
//  RegisterViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import UIKit
import FirebaseAuth
import SwiftUI

class RegisterViewController: UIViewController {

// MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pseudonymTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setRegisterButton()
    }

    // MARK: - IBAction
    /// Sign up a new user
    @IBAction func registerAction() {
        showActivityIndicator(shown: true)
        if checkPassword() {
            guard let displayName = pseudonymTextField.text,
                  !displayName.isEmpty,
                  let email = emailAddressTextField.text,
                  !email.isEmpty,
                  let password = passwordTextField.text
            else {
                showActivityIndicator(shown: false)
                presentAlertError(alertMessage: "Complete all fields")
                return
            }
            createUser(email, password, displayName)
        }
    }

    // MARK: - Private functions
    /// create a new user in database
    /// - Parameters:
    ///   - email: email new user's
    ///   - password: password new user's
    ///   - displayName: displayname new user's
    private func createUser(_ email: String, _ password: String, _ displayName: String) {
        UserServices.shared.createUser(
            email: email,
            password: password,
            displayName: displayName
        ) { [weak self] result in
            switch result {
            case .success(let user):
                self?.updateDisplayName(displayName: displayName, user: user)
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.showActivityIndicator(shown: false)
            }
        }
    }

    /// After create user transfer displayName value to the new user
    /// - Parameter displayName: displayName value
    private func updateDisplayName(displayName: String, user: User) {
        UserServices.shared.updateProfile(displayName: displayName) { [weak self] updateResult in
            switch updateResult {
            case .success(let user):
                self?.showActivityIndicator(shown: false)
                self?.presentNativeAlertSuccess(alertMessage: "\(user.displayName ?? "")" + " is created. \nGo in your emailbox for confirm your adress.".localized(tableName: "LocalizableRegisterViewController"), duration: 5)
                self?.goToLoginController(user: user)
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
        }
    }
}

    /// transfert to login controller for identification
    /// - Parameter user: new user create
    private func goToLoginController(user: User) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "Login") as? LoginViewController else {return}

        if let userMail = user.email {
            loginViewController.signInMail = userMail
        }

        UserServices.shared.disconnectCurrentUser { [weak self] result in
            switch result {
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            case .success(_):
                self?.navigationController?.setViewControllers([loginViewController], animated: true)            }
        }
    }

    /// Check fields if the same values
    /// - Returns: return true or false if password is good
    private func checkPassword() -> Bool {
        if passwordTextField.text == confirmPasswordTextField.text {return true}

        presentAlertError(alertMessage: "Your password is not similar")
        showActivityIndicator(shown: false)
        return false
    }

    /// Switch activity indicator and button
    /// - Parameter shown: transfer the boolean to isHiidden
    private func showActivityIndicator(shown: Bool) {
        activityIndicator.isHidden = !shown
        registerButton.isHidden = shown
    }

    private func setRegisterButton() {
        registerButton.layer.cornerRadius = registerButton.frame.height/2
    }
}

// MARK: - TextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case pseudonymTextField:
            emailAddressTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
           registerAction()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
