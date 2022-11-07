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
    func insertArea(area: Area, date: Date, uId: String?)
    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void)
    func getArea(nameArea: String?, callBack: @escaping (Result<Area, Error>) -> Void)
    func removeArea(name: String, callBack: @escaping(Result<String, Error>) -> Void)
}

class AreaServices: AreaServicesProtocol {

    // MARK: - properties
    static let shared = AreaServices()
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    private init() {}

    // MARK: - Database Area

    /// Insert a new area in database
    /// - Parameters:
    ///   - area: object area to insert
    ///   - date: date of creation
    func insertArea(area: Area, date: Date, uId: String?) {
        var index = 0
        guard let uId = uId else {
            return
        }
        let databaseArea = database.child("Database").child("users_list").child(uId).child("area_list")

        databaseArea.child(area.name!).setValue([
            "name": area.name,
            "date": area.date,
            "city": area.city
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

    /// insert to database of the user specific the area of the current hunter
    /// - Parameters:
    ///   - uId: Id of the user specific
    ///   - area: area of current user
    func transfertAreaIntoUserInForbidden(uId: String?, area: Area) {
        var index = 0
        guard let uId = uId else {return}
        let databaseAreaShared = database
            .child("Database")
            .child("users_list")
            .child(uId)
            .child("forbidden_area")

        databaseAreaShared.setValue([
            "name": area.name,
            "date": area.date,
            "city": area.city
        ])

        for point in area.coordinatesPoints {
            databaseAreaShared.child("coordinate").child("coordinate\(index)").setValue([
                "index": index,
                "latitude": point.latitude,
                "longitude": point.longitude
            ])
            index += 1
        }
    }

    /// get all area in user's database
    /// - Parameter callBack: switch an array area or error
    func getAreaList(callBack: @escaping (Result<[Area], Error>) -> Void) {
        var areaList: [Area] = []
        let databaseArea = database.child("Database").child("users_list")
        guard let user = firebaseAuth.currentUser else {
            callBack(.failure(ServicesError.signIn))
            return
        }
        areaList.removeAll()

        databaseArea.child(user.uid).child("area_list").getData { error, dataSnapshot in
            guard error == nil,
                  let dataSnapshot = dataSnapshot,
                  let data = dataSnapshot.children.allObjects as? [DataSnapshot],
                  data.count > 0
            else {
                callBack(.failure(error ?? ServicesError.noAreaRecordedFound))
                return
            }
            //            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot], data.count > 0 else {
            //                callBack(.failure(ServicesError.noAreaRecordedFound))
            //                return
            //            }

            for (index, dataArea) in data.enumerated() {
                let list = dataArea.value as? NSDictionary
                let name = list?["name"]
                let date = list?["date"]
                let city = list?["city"]
                let foldercoordinate = dataArea.childSnapshot(forPath: "coordinate").children.allObjects as? [DataSnapshot]

                guard let foldercoordinate = foldercoordinate else {return}
                //                let coordinateArea = self.createCoordinate(data: foldercoordinate)
                guard let name = name as? String, let date = date as? String else {return}

                let area = Area()
                area.name = name
                area.date = date
                area.city = city as? String
                area.coordinatesPoints = self.createCoordinate(data: foldercoordinate)
                areaList.append(area)

                if index == data.count-1 {
                    callBack(.success(areaList.sorted( by: { Int($0.date ?? "0") ?? 0 > Int($1.date ?? "0") ?? 0 })))
                }
            }
        }
    }

    /// get area selected
    /// - Parameters:
    ///   - nameArea: name area selected
    ///   - callBack: call result
    func getArea(nameArea: String?, callBack: @escaping (Result<Area, Error>) -> Void) {
        guard let nameArea = nameArea, !nameArea.isEmpty, let user = firebaseAuth.currentUser else {
            callBack(.failure(ServicesError.noAreaRecordedFound))
            return
        }

        let databaseArea = database
            .child("Database")
            .child("users_list")
            .child(user.uid)
            .child("area_list")
            .child(nameArea)
            .child("coordinate")

        databaseArea.getData { error, dataSnapshot in
            guard error == nil,
                  let dataSnapshot = dataSnapshot,
                  let data = dataSnapshot.children.allObjects as? [DataSnapshot]
            else {
                callBack(.failure(error ?? ServicesError.noAreaRecordedFound))
                return
            }

            let area = Area()
            area.name = nameArea
            area.coordinatesPoints = self.createCoordinate(data: data)
            callBack(.success(area))
        }
    }

    /// Get area hunt
    /// - Parameter uId: user id for access
    func getAreaForbidden(uId: String?, callback: @escaping (Result <Area, Error>) -> Void) {
        guard let uId else {return}
        let databaseAreaForbidden = database
            .child("Database")
            .child("users_list")
            .child(uId)
            .child("forbidden_area")
            .child("coordinate")

        databaseAreaForbidden.getData { error, dataSnapshot in
            guard error == nil,
                  let dataSnapshot,
                  let data = dataSnapshot.children.allObjects as? [DataSnapshot]

            else {return}
            let area = Area()
            area.coordinatesPoints = self.createCoordinate(data: data)
            callback(.success(area))
            }
        }

    /// delete area selected
    /// - Parameters:
    ///   - name: name area deleting
    ///   - callBack: call result
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

    /// organizes the coordinates of the area after the call
    /// - Parameter data: coordinates data receive
    /// - Returns: array coordinates's area
    private func createCoordinate(data: [DataSnapshot]) -> [CLLocationCoordinate2D] {
        var coordinateArea: [CLLocationCoordinate2D] = []
        var dictCoordinateArea: [Int: CLLocationCoordinate2D] = [:]
        dictCoordinateArea.removeAll()

        for element in data {
            let coordinateElement = element.value as? NSDictionary
            let latitude = coordinateElement?["latitude"]
            let longitude = coordinateElement?["longitude"]
            let index = coordinateElement?["index"]
            if let latitude = latitude as? Double, let longitude = longitude as? Double, let index = index as? Int {
                dictCoordinateArea[index] = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }

        // sort dictionary by index
        let sortedArray = dictCoordinateArea.sorted( by: { $0.key < $1.key})
        for dict in  0..<dictCoordinateArea.count {
            let list = sortedArray[dict]
            coordinateArea.append(list.value)
        }
        return coordinateArea
    }
}
