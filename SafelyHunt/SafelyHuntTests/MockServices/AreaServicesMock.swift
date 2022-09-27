//
//  AreaServicesMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 07/09/2022.
//

import Foundation
import Firebase
import CoreLocation
@testable import SafelyHunt

class AreaServicesMock: AreaServicesProtocol {
    var fakeData = FakeData()

    func insertArea(area: Area, date: Date) {
        let area = Area()
        fakeData.areas.append(area)
    }

    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void) {
        if !fakeData.areas.isEmpty, fakeData.resonseError == nil {
            callBack(.success(fakeData.areas))
        } else if let error = fakeData.resonseError {
            callBack(.failure(error))
        }
    }

    func getArea(nameArea: String?, callBack: @escaping (Result<Area, Error>) -> Void) {
        for area in fakeData.areas where area.name == nameArea {
//            if area.name == nameArea {
                callBack(.success(area))
//            }
        }
        callBack(.failure(fakeData.resonseError!))
    }

    func removeArea(name: String, callBack: @escaping (Result<String, Error>) -> Void) {
        var index = 0
        for area in fakeData.areas {
            if area.name == name {
                fakeData.areas.remove(at: index)
            }
            index += 1
        }
    }
}
