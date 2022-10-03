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

    /// Draw area with more info inside area list
    func testGivenListAreasWhenTapOnAccessoriesButtonThenDrawAreaSelected() {
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let appleAreaCellsQuery = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "Apple area")/*[[".cells.containing(.staticText, identifier:\"Cupertino\")",".cells.containing(.staticText, identifier:\"Apple area\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        appleAreaCellsQuery.element.tap()
        appleAreaCellsQuery.buttons["More Info"].tap()
        print(app.elementType.rawValue)
    }

    /// Draw a new area
    func testGivenNewAreaWhenPressMapForDrawAreaThenPolygonAreCreated() {
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Areas List"].buttons["Add"].tap()
        app.navigationBars["Editing area"].buttons["compose"].tap()

        let vkpointfeatureMap = app/*@START_MENU_TOKEN@*/.maps.containing(.other, identifier: "Chevron").element/*[[".maps.containing(.other, identifier:\"Target\").element",".maps.containing(.other, identifier:\"Northwest YMCA\").element",".maps.containing(.other, identifier:\"Apple Infinite Loop\").element",".maps.containing(.other, identifier:\"Peninsula Bible Church Cupertino\").element",".maps.containing(.other, identifier:\"Cupertino Hotel\").element",".maps.containing(.other, identifier:\"Chevron\").element",".maps.containing(.other, identifier:\"VKPointFeature\").element"],[[[-1,6],[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
    }

    /// Draw radius Alert
    func testGivenSliderRadiusWhenMoveToValue400ThenUserDefaultGet400() {
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Define your radius alert"]/*[[".cells.staticTexts[\"Define your radius alert\"]",".staticTexts[\"Define your radius alert\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.sliders.element.adjust(toNormalizedSliderPosition: 0)
        app.sliders.element.adjust(toNormalizedSliderPosition: 0.19)
//        print(app.sliders.element.normalizedSliderPosition)
    }

    /// Test Start monitoring
    func testGivenAreaSelectedWhenStartMonitoringThenMonitoringIsStart() {
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Select your area hunt"]/*[[".cells.staticTexts[\"Select your area hunt\"]",".staticTexts[\"Select your area hunt\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "Apple area")/*[[".cells.containing(.staticText, identifier:\"Cupertino\")",".cells.containing(.staticText, identifier:\"Apple area\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.element.tap()
        app.navigationBars["Areas List"].buttons["Main"].tap()
        tablesQuery.buttons["Start monitoring"].tap()
    }

    /// Test show profil informations
    func testGivenProfilSettingWhenClickOnProfileThenSeeDisplaynameAndDistanceTotal() {
        if app.buttons["Dissmiss"].exists {
            app.buttons["Dissmiss"].tap()
        }
        app.tabBars["Tab Bar"].buttons["Contact Photo"].tap()
        app.tables.cells.containing(.staticText, identifier: "Profile").element.tap()

        XCTAssertTrue(app.staticTexts["yoyo"].exists)
        XCTAssertTrue(app.staticTexts["yoyo@wanadoo.fr"].exists)
    }

}
