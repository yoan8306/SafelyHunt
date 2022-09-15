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
    func insertMyPosition(userPosition: CLLocation, user: User, date: Int)
    func getPositionUsers(callBack: @escaping (Result<[Hunter], Error>) -> Void)
    func insertDistanceTraveled(user: User, distance: Double)
    func getDistanceTraveled(user: User, callBack: @escaping(Result<Double, Error>) -> Void)
}

class MonitoringServices: MonitoringServicesProtocol {

    var monitoring: Monitoring
    var startMonitoring: Bool
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()

    init (monitoring: Monitoring = Monitoring(), startMonitoring: Bool = false) {
        self.monitoring = monitoring
        self.startMonitoring = startMonitoring
    }

    func insertMyPosition(userPosition: CLLocation, user: User, date: Int) {
        database.child("Database").child("position_user").child(user.uid).setValue([
            "name": user.displayName ?? "no name",
            "date": String(date),
            "latitude": userPosition.coordinate.latitude,
            "longitude": userPosition.coordinate.longitude
        ])
    }

    func getPositionUsers(callBack: @escaping (Result<[Hunter], Error>) -> Void) {
        let databaseAllPositions = database.child("Database").child("position_user")
        var hunters: [Hunter] = []

        databaseAllPositions.getData { error, dataSnapshot in
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

    func insertDistanceTraveled(user: User, distance: Double) {
        getDistanceTraveled(user: user) { result in
            switch result {
            case .failure(_):
                return
            case .success(let distanceTraveled):
                let newDistanceTraveled = distance + distanceTraveled
                self.database.child("Database").child("users_list").child(user.uid).child("distance_traveled").setValue([
                    "Total_distance": newDistanceTraveled])
            }
        }
    }

    func getDistanceTraveled(user: User, callBack: @escaping(Result<Double, Error>) -> Void) {
        database.child("Database").child("users_list").child(user.uid).child("distance_traveled").child("Total_distance").getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.distanceTraveled))
                return
            }
            let distance = dataSnapshot.value as? Double
            callBack(.success(distance ?? 0.0))
        }
    }

    func checkUserIsRadiusAlert(callback: @escaping(Result<Bool, Error>) -> Void) {
        getPositionUsers { result in
            switch result {
            case .success(let hunters):
                self.addHuntersIntoList(huntersList: hunters)
                if self.monitoring.listHuntersInRadiusAlert.count > 0 {
                    callback(.success(true))
                } else {
                    callback(.success(false))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
        return area.contain(coordinate: positionUser)
    }

    func insertMyDistanceTraveled() {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        insertDistanceTraveled(user: user, distance: monitoring.currentDistance)
        monitoring.currentDistance = 0
        monitoring.currentTravel = []
        monitoring.lastLocation = nil
        monitoring.firstLocation = nil
    }

    func getTotalDistanceTraveled(callBack: @escaping (Result<Double, Error>) -> Void ) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        getDistanceTraveled(user: user) { result in
            switch result {
            case .failure(let error):
                callBack(.failure(error))
            case.success(let distance):
                callBack(.success(distance))
            }
        }
    }

    private func addHuntersIntoList(huntersList: [Hunter]) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }

        let myLatitude = monitoring.hunter.latitude ?? 0
        let myLongitude = monitoring.hunter.longitude ?? 0
        let myPosition = CLLocation(latitude: myLatitude, longitude: myLongitude)

        insertMyPosition(userPosition: myPosition, user: user, date: Int(Date().timeIntervalSince1970))

        self.monitoring.listHuntersInRadiusAlert = []

        for hunter in huntersList {
            guard let dateTimeStamp = hunter.date else {
                return
            }

            let lastUpdate = Date(timeIntervalSince1970: TimeInterval(dateTimeStamp))
            //            check if user is present less 20 minutes ago
            if lastUpdate.addingTimeInterval(1200) > Date() {
                let latitude = hunter.latitude ?? 0
                let longitude = hunter.longitude ?? 0
                let positionTheOther = CLLocation(latitude: latitude, longitude: longitude)
                let distance = myPosition.distance(from: positionTheOther)
                if Int(distance) < UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert) {
                    self.monitoring.listHuntersInRadiusAlert.append(hunter)
                }
            }
        }
    }

}
