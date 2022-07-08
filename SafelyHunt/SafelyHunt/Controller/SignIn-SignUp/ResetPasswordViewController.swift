//
//  ResetPasswordViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func resetActionButton() {
        guard let email = emailTextField.text else {
            return
        }
        FirebaseManagement.shared.resetPassword(email: email) { [weak self] resetResult in
            switch resetResult {
            case .success(let resetSuccess):
                self?.presentAlertSuccess(alertMessage: resetSuccess)
                self?.dismiss(animated: true)
                
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }
}
