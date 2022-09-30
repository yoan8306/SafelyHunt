//
//  TestDateExtension.swift
//  SafelyHuntTests
//
//  Created by Yoan on 29/09/2022.
//

import XCTest
@testable import SafelyHunt

class TestDateExtension: XCTestCase {

    func testGivenDateFormatDateWhenTransformToTimeStampThenTheDateIsFormatTimeStamp() {
        let dateFormatter = DateFormatter()
        let myDate = Date(timeIntervalSince1970: 1664352449)
        dateFormatter.timeZone = .current
       
        XCTAssertTrue(myDate.dateToTimeStamp() == 1664352449)
        XCTAssertEqual(myDate.getTime(), "10:07:29 AM")
        XCTAssertEqual(myDate.relativeDate(relativeTo: Date(timeIntervalSince1970: 1664352500)), "il y a 51 secondes")
    }
}
