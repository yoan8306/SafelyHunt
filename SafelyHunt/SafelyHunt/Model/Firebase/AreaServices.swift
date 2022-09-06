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
    // all functions
}

// MARK: - Sign in
class AreaServices: AreaServicesProtocol {

    // MARK: - properties
    static let shared = AreaServices()
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}

// MARK: - Database Area
    func insertArea(user: User, coordinate: [CLLocationCoordinate2D], nameArea: String, date: Int) {
        var index = 0
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")

        databaseArea.child(nameArea).setValue([
            "name": nameArea,
            "date": String(date)
        ])

        for point in coordinate {
            databaseArea.child(nameArea).child("coordinate").child("coordinate\(index)").setValue([
                "index": index,
                "latitude": point.latitude,
                "longitude": point.longitude
            ])
            index += 1
        }
    }

    func getAreaList(user: User, callBack: @escaping (Result<[[String: String]], Error>) -> Void) {
        var areaList: [[String: String]] = [[:]]
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")

        databaseArea.getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.noAreaRecordedFound))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.noAreaRecordedFound))
                return
            }

            areaList.removeAll()

            for element in data {
                let list = element.value as? NSDictionary
                let name = list?["name"]
                let date = list?["date"]
                if let name = name as? String, let date = date as? String {
                    areaList.append([name: date])
                }
            }
            callBack(.success(areaList))
        }
    }

    func getArea(nameArea: String?, user: User, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        guard let nameArea = nameArea, !nameArea.isEmpty else {
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

    func removeArea(name: String, user: User, callBack: @escaping(Result<DatabaseReference, Error>) -> Void) {
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list").child(name)
        databaseArea.removeValue { error, success in
            guard error == nil else {
                callBack(.failure(error ?? ServicesError.errorDeletingArea))
                return
            }
            callBack(.success(success))
        }
    }
}
