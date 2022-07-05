//
//  FirebaseManagement.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation
import FirebaseAuth

class FirebaseManagement {
   static let shared = FirebaseManagement()
    
  private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}
    
    func createUser(email: String, password: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        
        DispatchQueue.main.async {
            self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
                guard let result = authResult, error == nil else {
                    callBack(.failure(error ?? FirebaseError.createAccountError))
                    return
                }
                callBack(.success(result))
                if self.firebaseAuth.currentUser != nil {
//                    self.firebaseAuth.currentUser?.sendEmailVerification(beforeUpdatingEmail: email)
                    self.firebaseAuth.currentUser?.sendEmailVerification()
                   print(self.firebaseAuth.currentUser?.email ?? "my address email")
                }
               
            }
        }
    }
}
