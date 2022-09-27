//
//  TestAreaServices.swift
//  SafelyHuntTests
//
//  Created by Yoan on 02/09/2022.
//

import XCTest
import FirebaseAuth
@testable import SafelyHunt

class TestUserServices: XCTestCase {
    var userServicesMock = UserServicesMock()

    override func setUp() {
        userServicesMock.fakeData = FakeData()
        userServicesMock = UserServicesMock()
    }

    /// if user is logged return hunter with user signIn
    func testGivenUserIsLoggedWhenLaunchApplicationThenUserIsCallBack() {
        userServicesMock.fakeData.userSign = FirebaseAuth.Auth.auth().currentUser
        userServicesMock.checkUserLogged { hunter in
            switch hunter {
            case .success(let hunter):
                XCTAssertTrue(hunter.user == FirebaseAuth.Auth.auth().currentUser)
                XCTAssertTrue(hunter.displayName == FirebaseAuth.Auth.auth().currentUser?.displayName)
            case.failure(_):
                fatalError()
            }
        }
    }

    /// if user isn't signIn the function return failure
    func testGivenUserIsnotLoggedWhenLaunchApplicationThenCallBackFailure() {
        userServicesMock.fakeData.userSign = nil
        userServicesMock.fakeData.resonseError = ServicesError.signIn

        userServicesMock.checkUserLogged { result in
            switch result {
            case .success(_):
                fatalError()
            case.failure(let error):
                XCTAssertTrue(error.localizedDescription == ServicesError.signIn.localizedDescription)
            }
        }
    }

    /// create account, callback an user signIn
    func testGivenCreateUserWhenUserIsCreatedThenCallbackIsSuccess() {
        userServicesMock.fakeData.userSign = FirebaseAuth.Auth.auth().currentUser

        userServicesMock.createUser(email: FirebaseAuth.Auth.auth().currentUser!.email!, password: "password", displayName: FirebaseAuth.Auth.auth().currentUser!.displayName!) { result in
            switch result {
            case .success(let user):
                XCTAssertTrue(FirebaseAuth.Auth.auth().currentUser?.email == user.email)
                XCTAssertTrue(FirebaseAuth.Auth.auth().currentUser?.displayName == user.displayName)
            case .failure(_):
                fatalError()
            }
        }
    }

    /// create account callback error
    func testGivenCreateUserWhenAnErrorThenCallbackError() {
        userServicesMock.fakeData.resonseError = ServicesError.createAccountError

        userServicesMock.createUser(email: "yoan8306@wanadoo.fr", password: "password", displayName: "yoan8306") { result in
            switch result {
            case .success(_):
                fatalError()
            case .failure(let error):
                XCTAssertTrue(error.localizedDescription == ServicesError.createAccountError.localizedDescription)
            }
        }
    }

}
