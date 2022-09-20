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
    var responseError: Error?

    init(monitoring: MonitoringProtocol, startMonitoring: Bool, fakeData: FakeData? = nil, responseError: Error? = nil) {
        self.monitoring = monitoring
        self.startMonitoring = startMonitoring
        self.fakeData = fakeData
        self.responseError = responseError
    }

    func checkUserIsRadiusAlert(callback: @escaping (Result<[Hunter], Error>) -> Void) {
        <#code#>
    }

    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
        <#code#>
    }

    func insertDistanceTraveled() {
        print("insert into database")
    }

    func getTotalDistanceTraveled(callBack: @escaping (Result<Double, Error>) -> Void) {
        if let distanceDouble = fakeData?.distanceDouble {
            callBack(.success(distanceDouble))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }
}
