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
