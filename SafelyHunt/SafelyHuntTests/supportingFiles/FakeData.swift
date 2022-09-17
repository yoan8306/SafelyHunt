//
//  FakeData.swift
//  SafelyHuntTests
//
//  Created by Yoan on 07/09/2022.
//

import Foundation
import Firebase
import CoreLocation
@testable import SafelyHunt

class FakeData {
//    UserServicesMock
    var userIsLogged: String?
    var myStringMessage: String?
//    monitoringServices
    var arrayHunter: [Hunter]?
    var distanceDouble: Double?
//    areaServices
    var areaList: [Area] = []
    var areaCoordinate: [CLLocationCoordinate2D]?
    var removeAreaSuccess: Bool?
//    ResponseKO
    var responseKO = "i'm bad data".data(using: .utf8)
}
