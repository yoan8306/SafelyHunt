//
//  TestMonitoringServices.swift
//  SafelyHuntTests
//
//  Created by Yoan on 26/09/2022.
//

import XCTest
import CoreLocation
import MapKit
@testable import SafelyHunt

final class TestMonitoringServices: XCTestCase {
    var monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()), startMonitoring: false)
    var hunters: [Hunter] = []
    override func setUp() {
        super.setUp()
        monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()), startMonitoring: false)
        hunters = []
    }

    /// Test addHunters return all hunters
    func testGivenTheyHunterAreInRadiusAlertWhenGetPositionsHunterThenCallbackHunters() {
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

        let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(
            huntersList: hunters,
            actualPostion: actualPostion,
            radiusAlert: 300
        )

        XCTAssertTrue(huntersInRadiusAlert.count == hunters.count)
    }

    /// In radius alert they are 2 hunters on 3 hunters
    func testGivenThreeHuntersWhenTheyAreTwoHuntersInRadiusAlertThenCallbackTwoHunters() {
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
        
        let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(
            huntersList: hunters,
            actualPostion: actualPosition,
            radiusAlert: 300
        )
        
        XCTAssertTrue(2 == huntersInRadiusAlert.count)
        XCTAssertTrue(huntersInRadiusAlert.contains { hunter in
            hunter.displayName == hunterTwo.displayName
        }
        )
        XCTAssertTrue(huntersInRadiusAlert.contains { hunter in
            hunter.displayName == hunterThree.displayName
        }
)
    }

    /// 3hunters inside area but one hunter they are no date updated
    func testGiven3HuntersWhen1hunterTheyAreNoDateThenCanNotInsertThisHunter() {
        let hunterOne = Hunter()
        hunterOne.displayName = "yoan83"
        hunterOne.longitude = -122.02957434
        hunterOne.latitude = 37.33070248
        hunterOne.date = Date().dateToTimeStamp()

        let hunterTwo = Hunter()
        hunterTwo.displayName = "yoan8306"
        hunterTwo.longitude = -122.0312186
        hunterTwo.latitude = 37.33233141

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

        let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(
            huntersList: hunters,
            actualPostion: actualPostion,
            radiusAlert: 300
        )

        XCTAssertTrue(huntersInRadiusAlert.count == hunters.count-1)
        XCTAssertTrue(huntersInRadiusAlert.contains(where: { hunter in
            hunter.displayName == hunterThree.displayName
        }))
        XCTAssertTrue(huntersInRadiusAlert.contains(where: { hunter in
            hunter.displayName == hunterOne.displayName
        }))
    }

    /// Test radius alert if no hunters
    func testGivenNoPositionHunterFindedWhenAddHunterIntoRadiusAlertThenNoHunter() {
        let latitudeUser = 37.33233141
        let longitude = -122.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitude

        guard let actualPostion = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }

        let huntersInRadiusAlert = monitoringServices.addHuntersIntoList(
            huntersList: hunters,
            actualPostion: actualPostion,
            radiusAlert: 300
        )

        XCTAssertTrue(huntersInRadiusAlert.count == 0)
    }

    /// User is inside Area return true
    func testGivenUserIsInAreaWhenCheckUserThenAreaContainsReturnTrue() {
        let latitudeUser = 37.33233141
        let longitude = -122.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitude
        monitoringServices.monitoring.area = createArea()

        guard let actualPostion = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }

        XCTAssertTrue(monitoringServices.checkUserIsAlwayInArea(positionUser: actualPostion.coordinate))
    }

    /// If user is outside area function return false
    func testGivenUserIsOutsideAreaWhenCheckUserAndAreaThenReturnFalse() {
        let latitudeUser = 40.34245
        let longitude = -125.0312186
        monitoringServices.monitoring.hunter?.latitude = latitudeUser
        monitoringServices.monitoring.hunter?.longitude = longitude
        monitoringServices.monitoring.area = createArea()

        guard let actualPostion = monitoringServices.monitoring.hunter?.actualPostion else {
            fatalError()
        }
        XCTAssertFalse(monitoringServices.checkUserIsAlwayInArea(positionUser: actualPostion.coordinate))
    }

    /// Create are with coordinate
    /// - Returns: Area
    private func createArea() -> Area {
        let area = Area()
        var coordinate: [CLLocationCoordinate2D] = []
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32428915137889, longitude: -122.06397669446443))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.324360324515226, longitude: -122.06397669446443))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32464501964462, longitude: -122.06397669446443))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.332616077920974, longitude: -122.06281315695574))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.34129787095928, longitude: -122.05323633562364))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.346349930258185, longitude: -122.02862301601155))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.34563839441404, longitude: -122.00866384643433))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.34549608513322, longitude: -122.00714229832997))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.33987469678473, longitude: -121.99416436199931))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.33418172062572, longitude: -121.99219529757752))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.33354123392809, longitude: -121.99219529757752))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32912884275987, longitude: -121.99219529757752))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32663786512322, longitude: -121.99219529757752))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32500088948312, longitude: -121.99255330817314))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.320801529729806, longitude: -121.99389585302828))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.3162460289671, longitude: -121.99720746640226))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.31161906370848, longitude: -122.00526273553282))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.30969701025779, longitude: -122.01537657070986))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.30934107121378, longitude: -122.02047824115922))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.31133431923594, longitude: -122.03542524191171))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.31190381036117, longitude: -122.03775232102626))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.315249475046414, longitude: -122.04562858281045))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.319520322742335, longitude: -122.05099876223085))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.3210862415998, longitude: -122.05368385194106))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32229624361045, longitude: -122.05717446856431))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32265212457207, longitude: -122.05994905989913))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32322152995357, longitude: -122.0645137124065))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.323577403275266, longitude: -122.06603526460796))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.32364858034384, longitude: -122.06639327520364))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.323790927762545, longitude: -122.06728830783841))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.3238621046289, longitude: -122.0679148274051))
        coordinate.append(CLLocationCoordinate2D(latitude: 37.3238621046289, longitude: -122.06800432902975))
        area.coordinatesPoints = coordinate
        area.name = "Large Zone Apple"
        return area
    }
}
