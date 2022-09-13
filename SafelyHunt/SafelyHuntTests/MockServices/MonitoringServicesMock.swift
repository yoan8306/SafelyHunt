//
//  MonitoringServicesMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 07/09/2022.
//

import Foundation
import Firebase
import CoreLocation
@testable import SafelyHunt
import UIKit

class MonitoringServicesMock: MonitoringServicesProtocol {
    var fakeData: FakeData?
    var responseError: Error?

    func insertMyPosition(userPosition: CLLocation, user: User, date: Int) {
        print("Insert into database")
    }

    func getPositionUsers(callBack: @escaping (Result<[Hunter], Error>) -> Void) {
        if let arrayHunter = fakeData?.arrayHunter, arrayHunter.isEmpty != true {
            callBack(.success(arrayHunter))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func insertDistanceTraveled(user: User, distance: Double) {
        print("insert into database")
    }

    func getDistanceTraveled(user: User, callBack: @escaping (Result<Double, Error>) -> Void) {
        if let distanceDouble = fakeData?.distanceDouble {
            callBack(.success(distanceDouble))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }
}
