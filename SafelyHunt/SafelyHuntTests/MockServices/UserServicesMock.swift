//
//  UserServicesMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 25/08/2022.
//

import Foundation
import FirebaseAuth
@testable import SafelyHunt

class UserServicesMock: UserServicesProtocol {
    var fakeData = FakeData()

    func checkUserLogged(callBack: @escaping (Result<Hunter, Error>) -> Void) {
        if fakeData.userSign != nil, fakeData.resonseError == nil {
            let hunter = Hunter(displayName: fakeData.userSign!.displayName, user: fakeData.userSign!)
            callBack(.success(hunter))
        } else {
            callBack(.failure(fakeData.resonseError!))
        }
    }

    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<User, Error>) -> Void) {
        if let user = fakeData.userSign, fakeData.resonseError == nil {
            callBack(.success(user))
        } else if let responseError = fakeData.resonseError {
            callBack(.failure(responseError))
        }
    }

    func signInUser(email: String?, password: String?, callBack: @escaping (Result<String, Error>) -> Void) {
        if let myStringMessage = fakeData.myStringMessage, fakeData.resonseError == nil {
            callBack(.success(myStringMessage))
        } else if let responseError = fakeData.resonseError {
            callBack(.failure(responseError))
        }
    }

    func updateProfile(displayName: String, callBack: @escaping (Result<User, Error>) -> Void) {
        if let user = fakeData.userSign, fakeData.resonseError == nil {
            callBack(.success(user))
        } else if let responseError = fakeData.resonseError {
            callBack(.failure(responseError))
        }
    }

    func deleteAccount(password: String, callBack: @escaping (Result<String, Error>) -> Void) {
        if password == fakeData.password, fakeData.resonseError == nil {
            callBack(.success("user is deleted"))
        } else if let responseError = fakeData.resonseError {
            callBack(.failure(responseError))
        }
    }
}
