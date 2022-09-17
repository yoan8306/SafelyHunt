//
//  TestAreaServices.swift
//  SafelyHuntTests
//
//  Created by Yoan on 02/09/2022.
//

import XCTest
@testable import SafelyHunt

//class TestAreaServices: XCTestCase {
//    var hunter = Hunter()
//    let areaServicesMock = AreaServicesMock()
//
//    override func setUp() {
//        areaServicesMock.fakeResponseData.areaList.removeAll()
//        areaServicesMock.responseError =  nil
//        hunter = Hunter(area: Area(areaServices: areaServicesMock))
//    }
//
//    // Call insertArea succes
//    func testGivenNoAreaInDatabase_WhenInsertArea_ThenAreaIsInsertInList() {
//        hunter.area.insertArea(nameArea: "myArea")
//        hunter.area.getAreaList { callback in
//            switch callback {
//            case .failure(_):
//                fatalError()
//            case .success(let areaList):
//                let area = areaList[0]
//                XCTAssertTrue(area["name"] == "myArea")
//            }
//        }
//    }
//
//    // Call AreaList success
//    func testGivenAreaList_WhenGetGoodAreaList_ThenDataAreaListEqualAreaList() {
//        let myAreaList = [["Apple": "13453"], ["Marseille": "113456"]]
//        let responseData = FakeData()
//        responseData.areaList = myAreaList
//        areaServicesMock.fakeResponseData = responseData
//
//        hunter.area.getAreaList { callBack in
//            switch callBack {
//            case .success(let areaList):
//                self.hunter.areaList = areaList
//                XCTAssertEqual(self.hunter.areaList, myAreaList)
//
//            case .failure(_):
//                fatalError()
//            }
//        }
//    }
//
//    // call AreaList failed
//    func testGivenAreaList_WhenNoDataReceive_ThenReturnNoArea() {
//        let areaServicesMock = AreaServicesMock()
//        let hunter: Hunter = Hunter(area: Area(areaServices: areaServicesMock))
//        let responseError: String = ServicesError.noAreaRecordedFound.localizedDescription
//        areaServicesMock.responseError = ServicesError.noAreaRecordedFound
//
//        hunter.area.getAreaList { callBack in
//            switch callBack {
//            case .success(_):
//                fatalError()
//            case .failure(let error):
//                XCTAssertTrue(error.localizedDescription == responseError)
//            }
//        }
//    }
//}
