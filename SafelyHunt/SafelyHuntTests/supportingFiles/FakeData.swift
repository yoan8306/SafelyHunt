//
//  FakeData.swift
//  SafelyHuntTests
//
//  Created by Yoan on 07/09/2022.
//

import Foundation
import CoreLocation
import FirebaseAuth
@testable import SafelyHunt

class FakeData {
//    UserServicesMock
    var userSign: User?
    var myStringMessage: String?
    var password: String?

//    monitoringServices
    var hunters: [Hunter]?
    var distanceDouble: Double?
    var newDistanceInDatabase: Double?

//    areaServices
    var areas: [Area] = []
    var areaCoordinate: [CLLocationCoordinate2D]?
    var removeAreaSuccess: Bool?

//    ResponseKO
    var responseKO = "i'm bad data".data(using: .utf8)
    var resonseError: ServicesError?
}
