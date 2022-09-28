//
//  TestMonitoringServices.swift
//  SafelyHuntTests
//
//  Created by Yoan on 26/09/2022.
//

import XCTest
@testable import SafelyHunt
import CoreLocation

final class TestMonitoringServices: XCTestCase {
    var monitoringServicesMock = MonitoringServicesMock(monitoring: Monitoring(area: Area()), startMonitoring: false)
    var monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()), startMonitoring: false)

    override func setUp() {
        super.setUp()
        monitoringServicesMock = MonitoringServicesMock(monitoring: Monitoring(area: Area()), startMonitoring: false)
    }

    /// Test distance travelled
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

    /// Test addHunters return all hunters
    func testGivenTheyHunterAreInRadiusAlertWhenGetPositionsHunterThenCallbackHunters() {
        var hunters: [Hunter] = []
        let hunterOne = Hunter()
        hunterOne.displayName = "yoan83"
        hunterOne.longitude = -122.02957434
        hunterOne.latitude = 37.33070248
        hunterOne.date = Date().dateToTimeStamp()

        let hunterTwo = Hunter()
        hunterTwo.displayName = "yoan8306"
        hunterTwo.longitude = -122.0312186
        hunterTwo.latitude = 37.33233141
        hunterTwo.date = Date().dateToTimeStamp()

        let hunterThree = Hunter()
        hunterThree.displayName = "yoyo"
        hunterThree.latitude = 37.33233141
        hunterThree.longitude = -122.0312186
        hunterThree.date = Date().dateToTimeStamp()

        hunters.append(hunterOne)
        hunters.append(hunterTwo)
        hunters.append(hunterThree)

        let latitudeUser = 37.33233141
        let longitude = -122.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitude

        guard let actualPostion = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }

       let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(huntersList: hunters, actualPostion: actualPostion, radiusAlert: 300)

        XCTAssertTrue(huntersInRadiusAlert.count == hunters.count)
    }

    func testGivenThreeHuntersWhenTheyAreTwoHuntersInRadiusAlertThenCallbackTwoHunters() {
        var hunters: [Hunter] = []
        let hunterOne = Hunter()
        hunterOne.displayName = "yoan83"
        hunterOne.longitude = 200.02957434
        hunterOne.latitude = 17.33070248
        hunterOne.date = Date().dateToTimeStamp()

        let hunterTwo = Hunter()
        hunterTwo.displayName = "yoan8306"
        hunterTwo.longitude = -122.0312186
        hunterTwo.latitude = 37.33233141
        hunterTwo.date = Date().dateToTimeStamp()

        let hunterThree = Hunter()
        hunterThree.displayName = "yoyo"
        hunterThree.latitude = 37.33233141
        hunterThree.longitude = -122.0312186
        hunterThree.date = Date().dateToTimeStamp()

        hunters.append(hunterOne)
        hunters.append(hunterTwo)
        hunters.append(hunterThree)

        let latitudeUser = 37.33233141
        let longitudeUser = -122.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitudeUser

        guard let actualPosition = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }

       let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(huntersList: hunters, actualPostion: actualPosition, radiusAlert: 300)

        XCTAssertTrue(2 == huntersInRadiusAlert.count)
    }

    func testGivenNoPositionHunterFindedWhenAddHunterIntoRadiusAlertThenNoHunter() {
        let latitudeUser = 37.33233141
        let longitude = -122.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitude

        guard let actualPostion = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }

        let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(huntersList: [], actualPostion: actualPostion, radiusAlert: 300)

        XCTAssertTrue(huntersInRadiusAlert.count == 0)
    }
}
