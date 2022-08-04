//
//  LoginViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var signInMail: String = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = signInMail
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func logInActionButton() {
        activityIndicator(shown: true)
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            presentNativeAlertError(alertMessage: "Enter email and password")
            return
        }
        
        FirebaseManagement.shared.signInUser(email: email, password: password) { [weak self] authResult in
            switch authResult {
            case .success(_):
                self?.transferToMainStarter()
                self?.activityIndicator(shown: false)
                
            case .failure(let error):
                FirebaseManagement.shared.disconnectCurrentUser()
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.activityIndicator(shown: false)
            }
        }
    }
    

    
    private func transferToMainStarter() {
        let tabBarMain = UIStoryboard(name: "TabbarMain", bundle: nil)
        guard let mainStarter = tabBarMain.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {
            return
        }
        
        mainStarter.modalPresentationStyle = .fullScreen
        self.present(mainStarter, animated: true)
    }
    
    private func activityIndicator(shown: Bool) {
        logInButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
}
