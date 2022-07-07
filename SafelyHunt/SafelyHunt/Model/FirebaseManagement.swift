//
//  FirebaseManagement.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//
import UIKit
import Foundation
import FirebaseAuth

class FirebaseManagement {
    // MARK: - properties
    static let shared = FirebaseManagement()
    weak var handle: AuthStateDidChangeListenerHandle?
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}
    
    
    // MARK: - Functions
    func checkUserLogged(controller: UITabBarController) {
        handle = firebaseAuth.addStateDidChangeListener { auth, user in
            if ((user) != nil) {
                self.transfertToMainStarter(controller: controller)
                
            } else {
                self.transfertToLogin(controller: controller)
            }
        }
    }
    
    func removeStateChangeLoggedListen() {
        firebaseAuth.removeStateDidChangeListener(self.handle!)
    }
    
    func createUser(email: String, password: String, firstName: String, lastName: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let result = authResult, error == nil else {
                    callBack(.failure(error ?? FirebaseError.createAccountError))
                    return
                }
//                self.firebaseAuth.currentUser?.createProfileChangeRequest().displayName = "\(lastName), \(firstName)"
                callBack(.success(result))
                //                    if self.firebaseAuth.currentUser != nil {
                //                        self.firebaseAuth.currentUser?.sendEmailVerification()
                //                        print(self.firebaseAuth.currentUser?.email ?? "my address email")
                //                    }
            }
        }
        
    }
    
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(FirebaseError.signIn))
            return
        }
        
        self.firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let authResult = authResult, error == nil else {
                    callBack(.failure(error ?? FirebaseError.signIn))
                    return
                }
                callBack(.success(authResult))
            }
        }
    }
    
    func disconnectCurrentUser() {
        try? firebaseAuth.signOut()
    }
    
    func resetPassword(email: String, callBack: @escaping (Result<String, Error>) -> Void) {
        firebaseAuth.sendPasswordReset(withEmail: email) { error in
            if error == nil {
                callBack(.success("Email send"))
            }
            callBack(.failure(error ?? FirebaseError.resetPassword))
        }
    }
    
    // MARK: - Privates functions
    private func transfertToMainStarter(controller: UITabBarController) {
        let mainStarterStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "MainStarter") as? MainStarterViewController else {
            return
        }
        
        mainStarterViewController.modalPresentationStyle = .fullScreen
        removeStateChangeLoggedListen()
        controller.tabBarController?.setViewControllers([mainStarterViewController], animated: true)
    }
    
    private func transfertToLogin(controller: UITabBarController) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        
        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
            return
        }
        loginViewController.modalPresentationStyle = .fullScreen
        removeStateChangeLoggedListen()
        controller.present(loginViewController, animated: true)
    }
    
}
