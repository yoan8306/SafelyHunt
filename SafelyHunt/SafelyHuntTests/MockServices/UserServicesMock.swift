//
//  UserServicesMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 25/08/2022.
//

import Foundation
@testable import SafelyHunt

class UserServicesMock: UserServicesProtocol {
    var fakeData: FakeData?
    var responseError: Error?

    func checkUserLogged(callBack: @escaping (Result<String, Error>) -> Void) {
        if let userIsLogged = fakeData?.userIsLogged {
            callBack(.success(userIsLogged))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<String, Error>) -> Void) {
        if let myStringMessage = fakeData?.myStringMessage {
            callBack(.success(myStringMessage))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func signInUser(email: String?, password: String?, callBack: @escaping (Result<String, Error>) -> Void) {
        if let myStringMessage = fakeData?.myStringMessage {
            callBack(.success(myStringMessage))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func updateProfile(displayName: String, callBack: @escaping (Result<String, Error>) -> Void) {
        if let myStringMessage = fakeData?.myStringMessage {
            callBack(.success(myStringMessage))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func deleteAccount(password: String, callBack: @escaping (Result<String, Error>) -> Void) {
        if let myStringMessage = fakeData?.myStringMessage {
            callBack(.success(myStringMessage))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }
}
