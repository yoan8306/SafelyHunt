//
//  SafelyHuntUITestsLaunchTests.swift
//  SafelyHuntUITests
//
//  Created by Yoan on 30/09/2022.
//

import XCTest

class SafelyHuntUITestsLaunchTests: XCTestCase {
let app = XCUIApplication()
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testGivenListAreasWhenTapOnAccessoriesButtonThenDrawAreaSelected() {

        if app.buttons["Log in"].exists {
            app.buttons["Log in"].tap()
        }
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
    }

}
