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
   static let shared = FirebaseManagement()
    weak var handle: AuthStateDidChangeListenerHandle?
    
  private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}
    
    func checkUserLogged(controller: UIViewController) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if ((user) != nil) {
                print("User logged in")
                try? FirebaseAuth.Auth.auth().signOut()
            } else {
                print("Not Logged in")
                let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
                
                guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {
                    return
                }
                loginViewController.modalPresentationStyle = .fullScreen
                controller.present(loginViewController, animated: true)
            }
        }
    }
    
    func removeStateChangeLoggedListen() {
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
    func createUser(email: String, password: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        
       
            self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
                DispatchQueue.main.async {
                    guard let result = authResult, error == nil else {
                        callBack(.failure(error ?? FirebaseError.createAccountError))
                        return
                    }
                    callBack(.success(result))
//                    if self.firebaseAuth.currentUser != nil {
//                        self.firebaseAuth.currentUser?.sendEmailVerification()
//                        print(self.firebaseAuth.currentUser?.email ?? "my address email")
//                    }
                }
        }
    }
    
    
    
}
