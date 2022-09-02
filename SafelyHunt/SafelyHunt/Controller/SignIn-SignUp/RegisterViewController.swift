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
    @IBOutlet weak var pseudonym: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

// MARK: - IBAction
    @IBAction func registerAction() {
        showActivityIndicator(shown: true)
        if checkPassword() {
            guard let displayName = pseudonym.text, !displayName.isEmpty, let email = emailAddressTextField.text, !email.isEmpty, let password = passwordTextField.text else {
                showActivityIndicator(shown: false)
                presentAlertError(alertMessage: "Complete all field")
                return
            }
            createUser(email, password, displayName)
        }
    }
    
// MARK: - Private functions
    private func createUser(_ email: String, _ password: String, _ displayName: String) {
        FirebaseManagement.shared.createUser(email: email, password: password, displayName: displayName) { [weak self] result in
            switch result {
            case .success(_):
                self?.updateDisplayName(displayName: displayName)
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.showActivityIndicator(shown: false)
            }
        }
    }
    
    /// After create user transfer displayName value to the new user
    /// - Parameter displayName: displayName value
    private func updateDisplayName(displayName: String) {
        FirebaseManagement.shared.updateProfile(displayName: displayName) { [weak self] updateResult in
            switch updateResult {
            case .success(let auth):
                self?.showActivityIndicator(shown: false)
                self?.presentNativeAlertSuccess(alertMessage: "User \(auth.currentUser?.displayName ?? "") is created")
                self?.goToLoginController()
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
        }
    }
}
    
    private func goToLoginController() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "Login") as? LoginViewController else {
            return
        }
        if let userMail = FirebaseAuth.Auth.auth().currentUser?.email {
            loginViewController.signInMail = userMail
        }
        
        FirebaseManagement.shared.disconnectCurrentUser()
        navigationController?.setViewControllers([loginViewController], animated: true)
    }
    
    /// Check fields if the same values
    /// - Returns: return true or false if password is good
    private func checkPassword() -> Bool {
        if passwordTextField.text == confirmPasswordTextField.text {
            return true
        }
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
    
}

// MARK: - TextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case pseudonym:
            emailAddressTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            print("continue")
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
