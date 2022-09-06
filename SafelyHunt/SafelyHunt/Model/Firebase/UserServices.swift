//
//  UserServices.swift
//  SafelyHunt
//
//  Created by Yoan on 05/09/2022.
//

import Foundation
import  FirebaseAuth
import Firebase

protocol UserServicesProtocol {
    func checkUserLogged(callBack: @escaping (Result<Bool, Error>) -> Void)
    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void)
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<AuthDataResult, Error>) -> Void)
    func updateProfile(displayName: String, callBack: @escaping (Result<Auth, Error>) -> Void)
    func deleteAccount(password: String, callBack: @escaping (Result<String, Error>) -> Void)
}

class UserServices: UserServicesProtocol {
   static var shared = UserServices()
    weak var handle: AuthStateDidChangeListenerHandle?
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()

   private init() {}

    func checkUserLogged(callBack: @escaping (Result<Bool, Error>) -> Void) {
        handle = firebaseAuth.addStateDidChangeListener { _, user in
            if (user) != nil {
                callBack(.success(true))
            } else {
                callBack(.failure(ServicesError.signIn))
            }
        }
    }

    func removeStateChangeLoggedListen() {
        firebaseAuth.removeStateDidChangeListener(self.handle!)
    }

    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let result = authResult, error == nil else {
                    callBack(.failure(error ?? ServicesError.createAccountError))
                    return
                }
                callBack(.success(result))
            }
        }
    }

    func signInUser(email: String?, password: String?, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(ServicesError.signIn))
            return
        }

        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let authResult = authResult, error == nil else {
                    callBack(.failure(error ?? ServicesError.signIn))
                    return
                }
                callBack(.success(authResult))
            }
        }
    }

    func updateProfile(displayName: String, callBack: @escaping (Result<Auth, Error>) -> Void) {
        let changeRequest = FirebaseAuth.Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    callBack(.failure(error ?? ServicesError.signIn))
                    return
                }
                callBack(.success(self.firebaseAuth))
            }
        })
    }

    func resetPassword(email: String, callBack: @escaping (Result<String, Error>) -> Void) {
        firebaseAuth.sendPasswordReset(withEmail: email) { error in
            if error == nil {
                callBack(.success("Email send"))
            }
            callBack(.failure(error ?? ServicesError.resetPassword))
        }
    }

    func disconnectCurrentUser(callBack: @escaping (Result<String, Error>) -> Void) {
        try? firebaseAuth.signOut()

        do {
            try firebaseAuth.signOut()
            callBack(.success("You are disconnected"))
        } catch {
            callBack(.failure(ServicesError.disconnected))
        }
    }

    func deleteAccount(password: String, callBack: @escaping (Result<String, Error>) -> Void) {
        let user = firebaseAuth.currentUser

        guard let user = user, let mail = user.email else {
            callBack(.failure(ServicesError.deleteAccountError))
            return
        }

        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: mail, password: password)

        user.reauthenticate(with: credential) { success, error  in
            if success != nil, error == nil {
                self.database.child("Database").child("users_list").child(user.uid).removeValue()
                self.database.child("Database").child("position_user").child(user.uid).removeValue()
                user.delete()

                self.disconnectCurrentUser { result in
                    switch result {
                    case .failure(_):
                        callBack(.failure(error ?? ServicesError.disconnected))
                    case .success(_):
                        callBack(.success("Delete Success"))
                    }
                }
            } else {
                callBack(.failure(error ?? ServicesError.deleteAccountError))
            }
        }
    }
}
