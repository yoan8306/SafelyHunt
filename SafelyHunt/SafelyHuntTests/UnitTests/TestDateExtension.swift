//
//  TestDateExtension.swift
//  SafelyHuntTests
//
//  Created by Yoan on 29/09/2022.
//

import XCTest
@testable import SafelyHunt

class TestDateExtension: XCTestCase {

    /// Test DateExtension
    func testGivenDateFormatDateWhenTransformToTimeStampThenTheDateIsFormatTimeStamp() {
        let myDate = Date(timeIntervalSince1970: 1664352449)
        XCTAssertTrue(myDate.dateToTimeStamp() == 1664352449)
        XCTAssertEqual(myDate.getTime(timeZone: TimeZone(secondsFromGMT: 0)!), "8:07:29 AM")
        XCTAssertEqual(
            myDate.relativeDate(relativeTo: Date(timeIntervalSince1970: 1664352500),
                                           locale: Locale(identifier: "en-US")), "51 seconds ago"
        )
    }
}
