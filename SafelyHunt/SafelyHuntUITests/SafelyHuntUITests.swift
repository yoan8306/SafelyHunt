//
//  SafelyHuntUITests.swift
//  SafelyHuntUITests
//
//  Created by Yoan on 30/09/2022.
//

import XCTest
import MapKit

class SafelyHuntUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    /// Test if bad email in SignIn present alert
    func testGivenBadAddressMailWhenPressLogInButtonThenAlertMessageExist() {
        let emailAddressTextField = app.textFields["email adress..."]
        let passwordSecureTextField = app.secureTextFields["Password..."]

        signOut()
        emailAddressTextField.tap()
        emailAddressTextField.typeText("Im bad email")
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("coucu")

        app.buttons["Log in"].tap()

        XCTAssertTrue(app.alerts["Error"].exists)
    }

    func testGivenInRegisterWithBadAdressMailWhenPressRegisterThenPresentAlert() {
        let pseudonymTexField = app.textFields["Pseudonym..."]
        let emailAddressTextField = app.textFields["email adress..."]
        let passwordTextField = app.secureTextFields["Password..."]
        let confirmPassword = app.secureTextFields["Confirm password..."]
        signOut()
        app.navigationBars["Log in"].buttons["Register"].tap()

        pseudonymTexField.tap()
        pseudonymTexField.typeText("ImUser test")
        emailAddressTextField.tap()
        emailAddressTextField.typeText("Im bad adress")
        passwordTextField.tap()
        passwordTextField.typeText("password")
        confirmPassword.tap()
        confirmPassword.typeText("password")

        app.buttons["Register"].tap()
        XCTAssertTrue(app.alerts["Error"].exists)
    }

    /// Draw area with more info inside area list
    func testGivenListAreasWhenTapOnAccessoriesButtonThenDrawAreaSelected() {
        let tablesQuery = app.tables
        let appleAreaCellsQuery = tablesQuery.cells.containing(.staticText, identifier:"Apple")
        signOut()
        signIn()
        tablesQuery.staticTexts["Select your hunting area"].tap()
        appleAreaCellsQuery.buttons["More Info"].tap()

        XCTAssertTrue(app.maps.element.exists)
    }

    /// Draw a new area
    func testGivenNewAreaWhenPressMapForDrawAreaThenPolygonAreCreated() {
        signIn()
        let app = XCUIApplication()

        app.tables.staticTexts["Select your hunting area"].tap()
        app.navigationBars["Areas List"].buttons["Add"].tap()
        app.navigationBars["Editing area"].buttons["compose"].tap()
        XCTAssertTrue(app.navigationBars["Draw your area"].exists)
    }

    /// Draw radius Alert
    func testGivenSliderRadiusWhenMoveToValue400ThenUserDefaultGet400() {
        signIn()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Define your radius alert"]/*[[".cells.staticTexts[\"Define your radius alert\"]",".staticTexts[\"Define your radius alert\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.sliders.element.adjust(toNormalizedSliderPosition: 0)
        app.sliders.element.adjust(toNormalizedSliderPosition: 0.19)
        XCTAssertTrue(app.navigationBars["Set radius alert"].exists)
    }

    /// Test Start monitoring
    func testGivenAreaSelectedWhenStartMonitoringThenMonitoringIsStart() {
        signIn()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Select your hunting area"].tap()
        tablesQuery.cells.containing(.staticText, identifier: "Apple").element.tap()
        app.navigationBars["Areas List"].buttons["Menu"].tap()
        app.buttons["Start monitoring"].tap()
        XCTAssertTrue(app.maps.element.exists)
    }

    /// Test show profil informations
    func testGivenProfilSettingWhenClickOnProfileThenSeeDisplaynameAndDistanceTotal() {
        signIn()
        app.tabBars["Tab Bar"].buttons["Contact Photo"].tap()
        app.tables.cells.containing(.staticText, identifier: "Profile").element.tap()

        XCTAssertTrue(app.staticTexts["yoan8306"].exists)
        XCTAssertTrue(app.staticTexts["yoan8306@wanadoo.fr"].exists)
    }

    private func signIn() {
        let emailAddressTextField = app.textFields["email adress..."]
        let passwordSecureTextField = app.secureTextFields["Password..."]

        if app.textFields["email adress..."].exists {
            emailAddressTextField.tap()
            emailAddressTextField.typeText("yoan8306@wanadoo.fr")
            passwordSecureTextField.tap()
            passwordSecureTextField.typeText("coucou")
        } else {
            return
        }
        
        
        app.buttons["Log in"].tap()
        app.buttons["Hunt"].tap()
        app.swipeLeft(velocity: XCUIGestureVelocity.fast)
        app.swipeDown(velocity: XCUIGestureVelocity.fast)
        
        if app.buttons["Dismiss"].exists {
            app.buttons["Dismiss"].tap()
        }
    }

    private func signOut() {
        if app.tabBars.element.exists {
            app.tabBars["Tab Bar"].buttons["Contact Photo"].tap()
            app.tables.cells.containing(.staticText, identifier: "Account").element.tap()
            app.staticTexts[" Disconnected"].tap()
        }
    }
}
