//
//  FirebaseManagement.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//
import UIKit
import Foundation
import FirebaseAuth
import Firebase
import MapKit

// MARK: - Authentification
class FirebaseManagement {

    // MARK: - properties
    static let shared = FirebaseManagement()
    weak var handle: AuthStateDidChangeListenerHandle?
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    
    private init() {}
    
    // MARK: - Functions
    func checkUserLogged(callBack: @escaping (Result<Bool, Error>) -> Void) {
        handle = firebaseAuth.addStateDidChangeListener { auth, user in
            if ((user) != nil) {
                callBack(.success(true))
            } else {
                callBack(.failure(FirebaseError.signIn))
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
                    callBack(.failure(error ?? FirebaseError.createAccountError))
                    return
                }
                callBack(.success(result))
            }
        }
    }
    
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(FirebaseError.signIn))
            return
        }
        
        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
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
    
    func updateProfile(displayName: String, callBack: @escaping (Result<Auth,Error>) -> Void) {
        let changeRequest = FirebaseAuth.Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    callBack(.failure(error ?? FirebaseError.signIn))
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
            callBack(.failure(error ?? FirebaseError.resetPassword))
        }
    }
}

// MARK: - Database
extension FirebaseManagement {
    
    func insertArea(user: User, coordinate: [CLLocationCoordinate2D], nameArea: String, date: Int) {
        var index = 0
        database.child("Database").child("users_list").child(user.uid).child("area_list").child(nameArea).setValue([
        "date": String(date)])
    
        for point in coordinate {
            database.child("Database").child("users_list").child(user.uid).child("area_list").child(nameArea).child("coordinate\(index)").setValue([
                "latitude": point.latitude,
                "longitude": point.longitude
            ])
            index += 1
        }
    }
}
