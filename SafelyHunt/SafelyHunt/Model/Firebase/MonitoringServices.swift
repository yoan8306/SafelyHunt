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

protocol MonitoringServicesProtocol {

}

class MonitoringServices: MonitoringServicesProtocol {
    static let shared = MonitoringServices()
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()

    private init() {}

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
            guard error != nil, let dataSnapshot = dataSnapshot else {
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
}
