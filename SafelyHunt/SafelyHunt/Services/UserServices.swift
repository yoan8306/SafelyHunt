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
    func createUser(
        email: String,
        password: String,
        displayName: String,
        callBack: @escaping (Result<User, Error>) -> Void
    )

    func signInUser(email: String?, password: String?, callBack: @escaping (Result<Bool, Error>) -> Void)
    func updateProfile(displayName: String, callBack: @escaping (Result<User, Error>) -> Void)
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
            if let user = user, user.isEmailVerified {
                let hunter = Hunter(displayName: user.displayName,
                                    user: user)
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
    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<User, Error>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let user = authResult?.user, error == nil else {
                    callBack(.failure(error ?? ServicesError.createAccountError))
                    return
                }
                self.sendEmailmVerification()
                callBack(.success(user))
            }
        }
    }

    /// Send emai verification
    func sendEmailmVerification() {
        guard let authUser = firebaseAuth.currentUser else {return}
        if !authUser.isEmailVerified {
            authUser.sendEmailVerification()
        }
    }

    /// Sign in user in application
    /// - Parameters:
    ///   - email: email's user sign in
    ///   - password: password user
    ///   - callBack: check if sign in is success
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<Bool, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(ServicesError.signIn))
            return
        }

        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard authResult != nil, error == nil else {
                    callBack(.failure(error ?? ServicesError.signIn))
                    return
                }
                guard let authUser = self.firebaseAuth.currentUser else { return }
                if authUser.isEmailVerified {
                    callBack(.success(true))
                } else {
                    callBack(.success(false))
                }
            }
        }
    }

    /// update user data and save in database
    /// - Parameters:
    ///   - displayName: user's displayname
    ///   - callBack: result of update
    func updateProfile(displayName: String, callBack: @escaping (Result<User, Error>) -> Void) {
        let user = firebaseAuth.currentUser
        guard let user = user else {return}
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
                callBack(.success(user))
            }
        })
    }

    /// disconnect the current user
    /// - Parameter callBack: return if disconnected is success or not
    func disconnectCurrentUser(callBack: @escaping (Result<String, Error>) -> Void) {
//        try? firebaseAuth.signOut()

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

        user.reauthenticate(with: credential) { authResult, error  in
            guard let userId = authResult?.user.uid, error == nil else {
                callBack(.failure(error ?? ServicesError.deleteAccountError))
                return
            }

            self.database.child("Database").child("users_list").child(userId).removeValue()
            self.database.child("Database").child("position_user").child(userId).removeValue()
            user.delete()

            self.disconnectCurrentUser { result in
                switch result {
                case .failure(_):
                    callBack(.failure(error ?? ServicesError.disconnected))
                case .success(_):
                    callBack(.success("Delete Success"))
                }
            }
        }
    }
}
