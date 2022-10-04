//
//  LoginViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: - Propertie
    var signInMail: String = ""

    // MARK: -  IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = signInMail

        #if DEBUG
        emailTextField.text = "yoyo@wanadoo.fr"
        passwordTextField.text = "coucou"
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - IBAction
    
    /// sign In user
    @IBAction func logInActionButton() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            presentNativeAlertError(alertMessage: "Enter email and password")
            return
        }
        activityIndicator(shown: true)

        UserServices.shared.signInUser(email: email, password: password) { [weak self] authResult in
            switch authResult {
            case .success(_):
                self?.transferToMainStarter()
                self?.activityIndicator(shown: false)

            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.activityIndicator(shown: false)
            }
        }
    }
    
    /// if user sign in transfert to mainStarterController
    private func transferToMainStarter() {
        let tabBarMain = UIStoryboard(name: "TabbarMain", bundle: nil)
        guard let mainStarter = tabBarMain.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {
            return
        }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarter, animationOption: .transitionFlipFromBottom)
    }
    
    /// show or hide activity indicator
    /// - Parameter shown: if true activity indicator is show
    private func activityIndicator(shown: Bool) {
        logInButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }
}
