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
    func checkUserLogged(callBack: @escaping (Result<Hunter, Error>) -> Void)
    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<String, Error>) -> Void)
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<String, Error>) -> Void)
    func updateProfile(displayName: String, callBack: @escaping (Result<String, Error>) -> Void)
    func deleteAccount(password: String, callBack: @escaping (Result<String, Error>) -> Void)
}

class UserServices: UserServicesProtocol {
// MARK: - Properties
   static var shared = UserServices()
    weak var handle: AuthStateDidChangeListenerHandle?
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()

   private init() {}

// MARK: - functions

    /// Check if an user is logged
    /// - Parameter callBack: if user is logged callback egual success
    func checkUserLogged(callBack: @escaping (Result<Hunter, Error>) -> Void) {
        handle = firebaseAuth.addStateDidChangeListener { _, user in
            if let user = user {
                let hunter = Hunter()
                hunter.user = user
                hunter.displayName = user.displayName
                callBack(.success(hunter))
            } else {
                callBack(.failure(ServicesError.signIn))
            }
        }
    }

    /// stop  listener state logged in or out
    func removeStateChangeLoggedListen() {
        firebaseAuth.removeStateDidChangeListener(self.handle!)
    }

    /// Create a new user in database firebase
    /// - Parameters:
    ///   - email: email for authenticate
    ///   - password: password's user
    ///   - displayName: displaynam user's
    ///   - callBack: check if user create is success or not
    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<String, Error>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let _ = authResult, error == nil else {
                    callBack(.failure(error ?? ServicesError.createAccountError))
                    return
                }
                callBack(.success("UserCreated"))
            }
        }
    }

    /// Sign in user in application
    /// - Parameters:
    ///   - email: email's user sign in
    ///   - password: password user
    ///   - callBack: check if sign in is success
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<String, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(ServicesError.signIn))
            return
        }

        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let _ = authResult, error == nil else {
                    callBack(.failure(error ?? ServicesError.signIn))
                    return
                }
                callBack(.success("UserSignIn"))
            }
        }
    }

    /// update user data and save in database
    /// - Parameters:
    ///   - displayName: user's displayname
    ///   - callBack: result of update
    func updateProfile(displayName: String, callBack: @escaping (Result<String, Error>) -> Void) {
        let user = firebaseAuth.currentUser
        guard let user = user else {
            return
        }
        let changeRequest = user.createProfileChangeRequest()

        changeRequest.displayName = displayName

        changeRequest.commitChanges(completion: { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    callBack(.failure(error ?? ServicesError.signIn))
                    return
                }
                self.database.child("Database").child("users_list").child(user.uid).child("info_user").setValue([
                    "name": user.displayName,
                    "email": user.email,
                    "uid": user.uid])
                callBack(.success("ProfileUpdated"))
            }
        })
    }

    /// reset password
    /// - Parameters:
    ///   - email: email for reset password
    ///   - callBack: result after click reset password
    func resetPassword(email: String, callBack: @escaping (Result<String, Error>) -> Void) {
        firebaseAuth.sendPasswordReset(withEmail: email) { error in
            if error == nil {
                callBack(.success("Email send"))
            }
            callBack(.failure(error ?? ServicesError.resetPassword))
        }
    }

    /// disconnect the current user
    /// - Parameter callBack: return if disconnected is success or not
    func disconnectCurrentUser(callBack: @escaping (Result<String, Error>) -> Void) {
        try? firebaseAuth.signOut()

        do {
            try firebaseAuth.signOut()
            callBack(.success("You are disconnected"))
        } catch {
            callBack(.failure(ServicesError.disconnected))
        }
    }

    /// delete user and all information in database firebase
    /// - Parameters:
    ///   - password: password for provide credential
    ///   - callBack: return success deleting user or show error
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
