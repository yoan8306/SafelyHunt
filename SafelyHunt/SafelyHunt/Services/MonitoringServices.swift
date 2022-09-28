//
//  MonitoringServices.swift
//  SafelyHunt
//
//  Created by Yoan on 05/09/2022.
//

import Foundation
import  FirebaseAuth
import Firebase
import CoreLocation
import MapKit

protocol MonitoringServicesProtocol {
    var monitoring: MonitoringProtocol {get}
    var startMonitoring: Bool {get set}
    func checkUserIsInRadiusAlert(callback: @escaping(Result<[Hunter], Error>) -> Void)
    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool
    func insertDistanceTraveled()
    func getTotalDistanceTraveled(callBack: @escaping(Result<Double, Error>) -> Void)
    func insertMyPosition()
}

class MonitoringServices: MonitoringServicesProtocol {
    var monitoring: MonitoringProtocol
    var startMonitoring: Bool
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()

    init (monitoring: MonitoringProtocol, startMonitoring: Bool = false) {
        self.monitoring = monitoring
        self.startMonitoring = startMonitoring
    }

    /// check if they are hunters in the radius of the user
    /// - Parameter callback: send true if an other hunter is in  radius
    func checkUserIsInRadiusAlert(callback: @escaping(Result<[Hunter], Error>) -> Void) {
        guard let hunter = monitoring.hunter else {
            callback(.failure(ServicesError.signIn))
            return
        }

//        let latitude = hunter.latitude ?? 0
//        let longitude = hunter.longitude ?? 0
        guard let actualPosition = hunter.actualPostion else {
            return
        }

        getPositionUsers { result in
            switch result {
            case .success(let hunters):
                callback(.success( self.addHuntersIntoList(huntersList: hunters, actualPostion: actualPosition, radiusAlert: UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert))))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    /// checks if the user is still in their hunting area
    /// - Parameters:
    ///   - area: polygon of area
    ///   - positionUser: user position
    /// - Returns: send true if user is still in their area
    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
        return area.contain(coordinate: positionUser)
    }

    /// add new total value of the distance total traveled in database
    /// - Parameters:
    ///   - user: current user
    ///   - distance: the distance to be added
    func insertDistanceTraveled() {
        let distance = monitoring.currentDistance
        guard let user = firebaseAuth.currentUser else {
            return
        }

        getTotalDistanceTraveled() { result in
            switch result {
            case .failure(_):
                return
            case .success(let distanceTraveled):
                let newDistanceTraveled = distance + distanceTraveled
                self.database.child("Database").child("users_list").child(user.uid).child("distance_traveled").setValue([
                    "Total_distance": newDistanceTraveled])
                self.monitoring.currentDistance = 0
                self.monitoring.currentTravel = []
                self.monitoring.lastLocation = nil
                self.monitoring.firstLocation = nil
            }
        }
    }

    /// get the totatl distance traveled
    /// - Parameters:
    ///   - user: current user
    ///   - callBack: send the total distance traveled
    func getTotalDistanceTraveled(callBack: @escaping(Result<Double, Error>) -> Void) {
        guard let user = firebaseAuth.currentUser else {
            return
        }
        database.child("Database").child("users_list").child(user.uid).child("distance_traveled").child("Total_distance").getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.distanceTraveled))
                return
            }
            let distance = dataSnapshot.value as? Double
            callBack(.success(distance ?? 0.0))
        }
    }

    /// get position of all users available in database
    /// - Parameter callBack: call result send array of hunter
    private func getPositionUsers(callBack: @escaping (Result<[Hunter], Error>) -> Void) {
        let databaseAllPositions = database.child("Database").child("position_user")
        var hunters: [Hunter] = []

        databaseAllPositions.getData { error, dataSnapshot  in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.listUsersPositions))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.listUsersPositions))
                return
            }
            guard let userId = self.firebaseAuth.currentUser?.uid else {
                return
            }

            for element in data where element.key != userId {
                let dictElement = element.value as? NSDictionary
                let displayName = dictElement?["name"] as? String
                let latitude = dictElement?["latitude"] as? Double
                let longitude = dictElement?["longitude"] as? Double
                let dateString = dictElement?["date"] as? String
                let date = Int(dateString ?? "0")
                let hunter = Hunter()
                hunter.displayName = displayName
                hunter.latitude = latitude
                hunter.longitude = longitude
                hunter.date = date
                hunters.append(hunter)
            }
            callBack(.success(hunters))
        }
    }

    /// insert hunters if they were seen less than 20 minutes ago
    /// - Parameter huntersList: all hunters in database
    func addHuntersIntoList(huntersList: [Hunter], actualPostion: CLLocation, radiusAlert: Int) -> [Hunter] {
        var hunterInradiusAlert: [Hunter] = []

        for hunter in huntersList {
            guard let dateTimeStamp = hunter.date else {
                continue
            }

            let lastUpdate = Date(timeIntervalSince1970: TimeInterval(dateTimeStamp))
            // check if user is present less 20 minutes ago
            if lastUpdate.addingTimeInterval(1200) > Date() {
                let latitude = hunter.latitude ?? 0
                let longitude = hunter.longitude ?? 0
                let hunterPositionFind = CLLocation(latitude: latitude, longitude: longitude)
                let distance = actualPostion.distance(from: hunterPositionFind)
                if Int(distance) < radiusAlert {
                    hunterInradiusAlert.append(hunter)
                }
            }
        }
        return hunterInradiusAlert
    }

    /// insert position of current user in database
    /// - Parameters:
    ///   - userPosition: position user
    ///   - user: current user
    ///   - date: date of insert position
     func insertMyPosition() {
         guard let user = firebaseAuth.currentUser, let latitude = monitoring.hunter?.latitude, let longitude = monitoring.hunter?.longitude else {
             return
         }
        database.child("Database").child("position_user").child(user.uid).setValue([
            "name": user.displayName ?? "no name",
            "date": String(Int(Date().timeIntervalSince1970)),
            "latitude": latitude,
            "longitude": longitude
        ])
    }
}
