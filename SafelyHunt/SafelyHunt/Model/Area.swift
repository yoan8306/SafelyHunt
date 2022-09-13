//
//  Area.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import Foundation
import MapKit
import FirebaseAuth

class Area {
    var areaServices: AreaServicesProtocol
    var coordinatesPoints: [CLLocationCoordinate2D] = []
    var coordinateTravel: [CLLocationCoordinate2D] = []
    var areaSelected: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) ?? ""
        }
    }
    var radiusAlert: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert)
        }
    }

    init(areaServices: AreaServicesProtocol = AreaServices.shared, coordinatesPoints: [CLLocationCoordinate2D] = [], coordinateTravel: [CLLocationCoordinate2D] = []) {
        self.areaServices = areaServices
        self.coordinatesPoints = coordinatesPoints
        self.coordinateTravel = coordinateTravel
    }

    func createPolyLineTravel() -> MKOverlay {
        MKPolyline(coordinates: coordinateTravel, count: coordinateTravel.count)
    }

    func createPolyLine() -> MKOverlay {
     MKPolyline(coordinates: coordinatesPoints, count: coordinatesPoints.count)
    }

    func createPolygon() -> MKOverlay {
        MKPolygon(coordinates: coordinatesPoints, count: coordinatesPoints.count)
    }

    func createCircle(userPosition: CLLocationCoordinate2D, radius: CLLocationDistance) -> MKOverlay {
        MKCircle(center: userPosition, radius: radius)
    }

    func getAreaList(callBack: @escaping (Result<[[String: String]], Error>) -> Void) {
        areaServices.getAreaList() { fetchArea in
            switch fetchArea {
            case .success(let areaList):
                callBack(.success(areaList))
            case .failure(let error):
                callBack(.failure(error))
            }
        }
    }

    func insertArea(nameArea: String?) {
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        let dateToTimeStamp = Int(dateStamp)

        guard let user = FirebaseAuth.Auth.auth().currentUser, let nameArea = nameArea else {
            return
        }

        areaServices.insertArea(user: user, coordinate: coordinatesPoints, nameArea: nameArea, date: dateToTimeStamp)
    }

    func getArea(nameArea: String?, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        areaServices.getArea(nameArea: nameArea) { result in
            switch result {
            case .success(let coordinate):
                callBack(.success(coordinate))
            case .failure(let error):
                callBack(.failure(error))
            }
        }
    }
}
