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

    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resetPasswordButton: UIButton!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = signInMail
        setLoginButton()
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
            case .success(let emailIsChecked):
                switch emailIsChecked {
                case true:
                    self?.transferToMainStarter()
                    self?.activityIndicator(shown: false)
                case false:
                    self?.activityIndicator(shown: false)
                    self?.presentSendEmailVerification()
                }

            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.activityIndicator(shown: false)
            }
        }
    }

    @IBAction func resetPasswordAction() {
        presentResetPassword()
    }

    /// if user sign in transfert to mainStarterController
    private func transferToMainStarter() {
        let tabBarMain = UIStoryboard(name: "TabbarMain", bundle: nil)
        guard let mainStarter = tabBarMain.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {return}

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarter, animationOption: .transitionFlipFromRight)
    }

    /// show or hide activity indicator
    /// - Parameter shown: if true activity indicator is show
    private func activityIndicator(shown: Bool) {
        logInButton.isHidden = shown
        activityIndicator.isHidden = !shown
    }

    private func setLoginButton() {
        logInButton.layer.cornerRadius = logInButton.frame.height/2
    }

    private func presentSendEmailVerification() {
        let alertVC = UIAlertController(
            title: "Your adress mail is not verify",
            message: "Go in your email box and click on link. Checked your spam. /nWould you like send a new mail",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.dismiss(animated: true)
        }
        let openSetting = UIAlertAction(title: "Send email", style: .default) { _ in
            guard let authUser = FirebaseAuth.Auth.auth().currentUser else {
                print("no user identify")
                return
            }
            print(authUser.email ?? "no email")
            UserServices.shared.sendEmailmVerification()
        }
        cancel.setValue(UIColor.label, forKey: "titleTextColor")
        openSetting.setValue(UIColor.label, forKey: "titleTextColor")
        alertVC.addAction(cancel)
        alertVC.addAction(openSetting)
        present(alertVC, animated: true, completion: nil)
    }

    private func presentResetPassword() {
        let alertViewController = UIAlertController(
            title: "Reset password",
            message: "Enter your email for reset your password",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }

        //        test if empty
        let resetPassword = UIAlertAction(title: "Send reset password", style: .default) { _ in
            if let textfield = alertViewController.textFields?[0], let email = textfield.text, !email.isEmpty {
                Auth.auth().sendPasswordReset(withEmail: email)
                self.presentNativeAlertSuccess(alertMessage: "An email has been sending")
            }
        }

        alertViewController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Your email..."
        })
        cancel.setValue(UIColor.label, forKey: "titleTextColor")
        resetPassword.setValue(UIColor.label, forKey: "titleTextColor")
        alertViewController.addAction(cancel)
        alertViewController.addAction(resetPassword)

        present(alertViewController, animated: true, completion: nil)
    }
}
