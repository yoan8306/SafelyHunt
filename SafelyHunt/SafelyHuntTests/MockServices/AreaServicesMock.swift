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
    var fakeResponseData = FakeData()
    var responseError: Error?

    func insertArea(user: User, coordinate: [CLLocationCoordinate2D], nameArea: String, date: Int) {
        let area = ["name": nameArea, "date": String(date)]
        fakeResponseData.areaList.append(area)
    }

    func getAreaList(callBack: @escaping (Result<[[String: String]], Error>) -> Void) {
        guard responseError == nil else {
            callBack(.failure(responseError ?? ServicesError.noAreaRecordedFound))
            return
        }
        callBack(.success(fakeResponseData.areaList))
    }

    func getArea(nameArea: String?, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        if let areaCoordinate = fakeResponseData.areaCoordinate {
            callBack(.success(areaCoordinate))
        } else if let responseError = responseError {
            callBack(.failure(responseError))
        }
    }

    func removeArea(name: String, user: User, callBack: @escaping (Result<String, Error>) -> Void) {
        if let removeAreaSuccess = fakeResponseData.removeAreaSuccess, removeAreaSuccess == true {
            callBack(.success("Remove area"))
        } else if let responseError = responseError {
                callBack(.failure(responseError))
        }
    }
}
