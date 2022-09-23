//
//  MonitoringServicesMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 07/09/2022.
//

import Foundation
import Firebase
import MapKit
import UIKit
@testable import SafelyHunt

class MonitoringServicesMock: MonitoringServicesProtocol {
    var monitoring: MonitoringProtocol
    var startMonitoring: Bool
    var fakeData: FakeData?

    init(monitoring: MonitoringProtocol, startMonitoring: Bool, fakeData: FakeData? = nil) {
        self.monitoring = monitoring
        self.startMonitoring = startMonitoring
        self.fakeData = fakeData
    }

    func checkUserIsRadiusAlert(callback: @escaping (Result<[Hunter], Error>) -> Void) {
        if fakeData?.resonseError == nil, let hunters = fakeData?.hunters {
            let latitude = monitoring.hunter?.latitude ?? 0
            let longitude = monitoring.hunter?.longitude ?? 0
            let myPosition = CLLocation(latitude: latitude, longitude: longitude)
            callback(.success(addHuntersIntoList(huntersList: hunters, myPosition: myPosition)))

        } else if let error = fakeData?.resonseError {
            callback(.failure(error))
        }
    }

    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
        return area.contain(coordinate: positionUser)
    }

    func insertDistanceTraveled() {
        let myCurrentDistance = monitoring.currentDistance
        getTotalDistanceTraveled { myOldDistance in
            switch myOldDistance {
            case .success(let oldDistance):
                self.fakeData?.newDistanceInDatabase = myCurrentDistance + oldDistance
            case .failure(_):
                return
            }
        }
    }

    func getTotalDistanceTraveled(callBack: @escaping (Result<Double, Error>) -> Void) {
        if let distanceDouble = fakeData?.distanceDouble, fakeData?.resonseError == nil {
            callBack(.success(distanceDouble))
        } else if let responseError = fakeData?.resonseError {
            callBack(.failure(responseError))
        }
    }

    private func addHuntersIntoList(huntersList: [Hunter], myPosition: CLLocation) -> [Hunter] {
        var hunterInradiusAlert: [Hunter] = []

        for hunter in huntersList {
            guard let dateTimeStamp = hunter.date else {
                continue
            }

            let lastUpdate = Date(timeIntervalSince1970: TimeInterval(dateTimeStamp))
            // check if user is present less 20 minutes ago
            if lastUpdate.addingTimeInterval(1200) > Date() {
                let latitude = hunter.latitude ?? 0
                let longitude = hunter.longitude ?? 0
                let hunterPositionFind = CLLocation(latitude: latitude, longitude: longitude)
                let distance = myPosition.distance(from: hunterPositionFind)
                if Int(distance) < 300 {
                    hunterInradiusAlert.append(hunter)
                }
            }
        }
        return hunterInradiusAlert
    }
}
