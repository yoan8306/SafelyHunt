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
    func testGivenBadAdressMailWhenPressLogInButtonThenAlertMessageExist() {
        let emailAdressTextField = app.textFields["email adress..."]
        let passwordSecureTextField = app.secureTextFields["Password..."]

        signOut()

        emailAdressTextField.tap()
        emailAdressTextField.typeText("Im bad email")
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("coucu")

        app.buttons["Log in"].tap()

        XCTAssertTrue(app.alerts["Error"].exists)
    }

    func testGivenInRegisterWithBadAdressMailWhenPressRegisterThenPresentAlert() {
        let pseudonymTexField = app.textFields["Pseudonym..."]
        let emailAdressTextField = app.textFields["email adress..."]
        let passwordTextField = app.secureTextFields["Password..."]
        let confirmPassword = app.secureTextFields["Confirm password..."]
        signOut()
        app.navigationBars["Log in"].buttons["Register"].tap()

        pseudonymTexField.tap()
        pseudonymTexField.typeText("ImUser test")
        emailAdressTextField.tap()
        emailAdressTextField.typeText("Im bad adress")
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
        let appleAreaCellsQuery = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "Apple area")/*[[".cells.containing(.staticText, identifier:\"Cupertino\")",".cells.containing(.staticText, identifier:\"Apple area\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/

        signIn()

        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        appleAreaCellsQuery.element.tap()
        appleAreaCellsQuery.buttons["More Info"].tap()

        XCTAssertTrue(app.maps.element.exists)

    }

    /// Draw a new area
    func testGivenNewAreaWhenPressMapForDrawAreaThenPolygonAreCreated() {
        signIn()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Areas List"].buttons["Add"].tap()
        app.navigationBars["Editing area"].buttons["compose"].tap()
    }

    /// Draw radius Alert
    func testGivenSliderRadiusWhenMoveToValue400ThenUserDefaultGet400() {
        signIn()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Define your radius alert"]/*[[".cells.staticTexts[\"Define your radius alert\"]",".staticTexts[\"Define your radius alert\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.sliders.element.adjust(toNormalizedSliderPosition: 0)
        app.sliders.element.adjust(toNormalizedSliderPosition: 0.19)
    }

    /// Test Start monitoring
    func testGivenAreaSelectedWhenStartMonitoringThenMonitoringIsStart() {
        signIn()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "Apple area")/*[[".cells.containing(.staticText, identifier:\"Cupertino\")",".cells.containing(.staticText, identifier:\"Apple area\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.element.tap()
        app.navigationBars["Areas List"].buttons["Main"].tap()
        tablesQuery.buttons["Start monitoring"].tap()
    }

    /// Test show profil informations
    func testGivenProfilSettingWhenClickOnProfileThenSeeDisplaynameAndDistanceTotal() {
        signIn()
        app.tabBars["Tab Bar"].buttons["Contact Photo"].tap()
        app.tables.cells.containing(.staticText, identifier: "Profile").element.tap()

        XCTAssertTrue(app.staticTexts["yoyo"].exists)
        XCTAssertTrue(app.staticTexts["yoyo@wanadoo.fr"].exists)
    }

    private func signIn() {
        if app.buttons["Log in"].exists {
            app.buttons["Log in"].tap()
        }
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
    }

    private func signOut() {
        if app.tabBars.element.exists {
            app.tabBars["Tab Bar"].buttons["Contact Photo"].tap()
            app.tables.cells.containing(.staticText, identifier: "Account").element.tap()
            app/*@START_MENU_TOKEN@*/.staticTexts["Disconnected"]/*[[".buttons[\"Disconnected\"].staticTexts[\"Disconnected\"]",".staticTexts[\"Disconnected\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
    }

}
