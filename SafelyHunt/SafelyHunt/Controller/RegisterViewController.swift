//
//  RegisterViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

   
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func registerAction() {
      
        if checkPassword() {
            guard let firstName = firstNameTextField.text, !firstName.isEmpty, let lastName = lastNameTextField.text, !lastName.isEmpty, let email = emailAddressTextField.text, !email.isEmpty, let password = passwordTextField.text else {
                return
            }
            FirebaseManagement.shared.createUser(email: email, password: password) { [weak self] result in
                switch result {
                case .success(let user):
                    self?.presentNativeAlertSuccess(alertMessage: "User \(user.user.email ?? email) id created")
//                    self?.dissmissViewController()
                case .failure(let error):
                    self?.presentAlertError(alertMessage: error.localizedDescription)
                }
            }
        }
    }
    
//    private func dissmissViewController() {
//        dismiss(animated: true)
//    }

    private func checkPassword() -> Bool {
        if passwordTextField.text == confirmPasswordTextField.text {
            return true
        }
        return false
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
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
