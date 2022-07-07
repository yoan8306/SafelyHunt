//
//  LoginViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func logInActionButton() {
        activityIndicator(shown: true)
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            presentNativeAlertError(alertMessage: "Enter email and password")
            return
        }
        
        FirebaseManagement.shared.signInUser(email: email, password: password) { authResult in
            switch authResult {
            case .success(let userSignIn):
                print(userSignIn.user.providerID)
                self.transfertToMainStarter()
                self.activityIndicator(shown: false)
                
            case .failure(let error):
                FirebaseManagement.shared.disconnectCurrentUser()
                self.presentAlertError(alertMessage: error.localizedDescription)
                self.activityIndicator(shown: false)
            }
        }
    }
    

    
    private func transfertToMainStarter() {
        let splashScreen = UIStoryboard(name: "Main", bundle: nil)
        guard let splashScreenViewController = splashScreen.instantiateViewController(withIdentifier: "SplashScreenStoryboard") as? SplashScreenViewController else {
            return
        }
        
        splashScreenViewController.modalPresentationStyle = .fullScreen
        self.present(splashScreenViewController, animated: true)
    }
    
    private func activityIndicator(shown: Bool) {
        logInButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
}
