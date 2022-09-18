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

    func insertArea(area: Area, date: Date) {
        let area = Area()
        fakeResponseData.areaList.append(area)
    }

    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void) {
        guard responseError == nil else {
            callBack(.failure(responseError ?? ServicesError.noAreaRecordedFound))
            return
        }
        callBack(.success(fakeResponseData.areaList))
    }

    func getArea(nameArea: String?, callBack: @escaping (Result<Area, Error>) -> Void) {
        <#code#>
    }

    func removeArea(name: String, callBack: @escaping (Result<String, Error>) -> Void) {
        if let removeAreaSuccess = fakeResponseData.removeAreaSuccess, removeAreaSuccess == true {
            callBack(.success("Remove area"))
        } else if let responseError = responseError {
                callBack(.failure(responseError))
        }
    }
}
