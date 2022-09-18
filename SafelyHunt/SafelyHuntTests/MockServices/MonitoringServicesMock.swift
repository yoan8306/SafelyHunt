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
    var fakeData: FakeData?
    var responseError: Error?

    func checkUserIsRadiusAlert(callback: @escaping (Result<Bool, Error>) -> Void) {
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
