//
//  SafelyHuntUITests.swift
//  SafelyHuntUITests
//
//  Created by Yoan on 30/09/2022.
//

import XCTest

class SafelyHuntUITests: XCTestCase {
let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testGivenListAreasWhenTapOnAccessoriesButtonThenDrawAreaSelected() {
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
        let selectAreaPredicate = NSPredicate(format: "label beginswith 'Select your area hunt'")
          app.tables.buttons.element(matching: selectAreaPredicate).tap()
    }
}
