//
//  AreaServices.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//
import UIKit
import Foundation
import FirebaseAuth
import Firebase
import MapKit

protocol AreaServicesProtocol {
    func insertArea(area: Area, date: Date)
    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void)
    func getArea(nameArea: String?, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void)
    func removeArea(name: String, callBack: @escaping(Result<String, Error>) -> Void)
}

// MARK: - Sign in
class AreaServices: AreaServicesProtocol {

    // MARK: - properties
    static let shared = AreaServices()
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}

// MARK: - Database Area
    func insertArea(area: Area, date: Date) {
        guard let user = firebaseAuth.currentUser else {
            return
        }

        var index = 0
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")

        databaseArea.child(area.name!).setValue([
            "name": area.name,
            "date": area.date
        ])

        for point in area.coordinatesPoints {
            databaseArea.child(area.name!).child("coordinate").child("coordinate\(index)").setValue([
                "index": index,
                "latitude": point.latitude,
                "longitude": point.longitude
            ])
            index += 1
        }
    }

    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void) {
        var areaList: [Area] = []
        let databaseArea = database.child("Database").child("users_list")

        guard let user = firebaseAuth.currentUser else {
            callBack(.failure(ServicesError.signIn))
            return
        }

        databaseArea.child(user.uid).child("area_list").getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.noAreaRecordedFound))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.noAreaRecordedFound))
                return
            }

            areaList.removeAll()

            for (index, element) in data.enumerated() {
                let list = element.value as? NSDictionary
                let name = list?["name"]
                let date = list?["date"]

                if let name = name as? String, let date = date as? String {
                    self.getArea(nameArea: name) { result in
                        switch result {
                        case .failure(let error):
                            callBack(.failure(error))
                        case .success(let coordinateArea):
                            let area = Area()
                            area.name = name
                            area.date = date
                            area.coordinatesPoints = coordinateArea
                            areaList.append(area)
                            if index == data.count-1 {
                                callBack(.success(areaList))
                            }
                        }
                    }
                }
            }
        }
    }

    func getArea(nameArea: String?, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        guard let nameArea = nameArea, !nameArea.isEmpty, let user = firebaseAuth.currentUser else {
            callBack(.failure(ServicesError.noAreaRecordedFound))
            return
        }

        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list").child(nameArea).child("coordinate")
        var coordinateArea: [CLLocationCoordinate2D] = []
        var dictCoordinateArea: [Int: CLLocationCoordinate2D] = [:]
        dictCoordinateArea.removeAll()

        databaseArea.getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.noAreaRecordedFound))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.noAreaRecordedFound))
                return
            }

            for element in data {
                let coordinateElement = element.value as? NSDictionary
                let latitude = coordinateElement?["latitude"]
                let longitude = coordinateElement?["longitude"]
                let index = coordinateElement?["index"]
                if let latitude = latitude as? Double, let longitude = longitude as? Double, let index = index as? Int {
                    dictCoordinateArea[index] = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }

            if dictCoordinateArea.count <= 0 {
                callBack(.failure(ServicesError.noAreaRecordedFound))
                return
            }

            // sort dictionary by index
            let sortedArray = dictCoordinateArea.sorted( by: { $0.key < $1.key})
            for dict in  0..<dictCoordinateArea.count {
                let list = sortedArray[dict]
                coordinateArea.append(list.value)
            }

            callBack(.success(coordinateArea))

        }
    }

    func removeArea(name: String, callBack: @escaping(Result<String, Error>) -> Void) {
        guard let user = firebaseAuth.currentUser else {
            callBack(.failure(ServicesError.signIn))
            return
        }
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list").child(name)
        databaseArea.removeValue { error, success in
            guard error == nil else {
                callBack(.failure(error ?? ServicesError.errorDeletingArea))
                return
            }
            callBack(.success("Remove area success"))
        }
    }
}
