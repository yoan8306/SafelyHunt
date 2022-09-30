//
//  TestMonitoring.swift
//  SafelyHuntTests
//
//  Created by Yoan on 29/09/2022.
//

import XCTest
import CoreLocation
@testable import SafelyHunt

final class TestMonitoring: XCTestCase {
    var monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()), startMonitoring: false)

    override func setUp() {
        super.setUp()
        monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()), startMonitoring: false)
    }

    func testGivenPostionsWhengetCurrenttravelThenReturnDistanceInDouble() {
        let location1 = CLLocation(latitude: 37.33123666, longitude: 122.03076342)
        let location2 = CLLocation(latitude: 37.33115792, longitude: 122.03076154)
        var distance = monitoringServices.monitoring.measureDistanceTravelled(locations: [location1])
       distance = monitoringServices.monitoring.measureDistanceTravelled(locations: [location2])

        XCTAssertTrue(distance * 1000 == monitoringServices.monitoring.currentDistance)
    }

    func testGivenPositionUserWhenGetCurrentTravelThenCurrentTravelKeepHistory() {
        let location1 = CLLocation(latitude: 37.33123666, longitude: 122.03076342)
        let location2 = CLLocation(latitude: 37.33115792, longitude: 122.03076154)
        let locations = [location1, location2]

        monitoringServices.monitoring.getCurrentTravel(locations: locations)
        XCTAssertTrue(location1.coordinate.longitude == monitoringServices.monitoring.currentTravel[0].longitude)
        XCTAssertTrue(location2.coordinate.latitude == monitoringServices.monitoring.currentTravel[1].latitude)
    }

}
