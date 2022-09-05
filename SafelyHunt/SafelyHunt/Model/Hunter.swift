//
//  UserHunter.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import FirebaseAuth
import MapKit

class Hunter {
    var displayName: String?
    var areaList: [[String: String]]?
    var latitude: Double?
    var longitude: Double?
    var user: User?
    var date: Int?

    var monitoring = Monitoring()
    var area = Area()
    var currentDistance: Double = 0.0
    var currentTravel: [CLLocationCoordinate2D] = []
    private var lastLocation: CLLocation!
    private var firstLocation: CLLocation?

    func measureDistanceTravelled(locations: [CLLocation]) -> Double {
        if firstLocation == nil {
            firstLocation = locations.first
        } else if let location = locations.last {
            currentDistance += lastLocation.distance(from: location)
        }
        lastLocation = locations.last
        return currentDistance / 1000
    }

    func getCurrentTravel(locations: [CLLocation]) {
        for location in locations {
            currentTravel.append(location.coordinate)
        }
    }

    func insertMyDistanceTraveled() {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        FirebaseManagement.shared.insertDistanceTraveled(user: user, distance: currentDistance)
        currentDistance = 0
        currentTravel = []
        lastLocation = nil
        firstLocation = nil
    }

    func getTotalDistanceTraveled(callBack: @escaping (Result<Double, Error>) -> Void ) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        FirebaseManagement.shared.getDistanceTraveled(user: user) { result in
            switch result {
            case .failure(let error):
                callBack(.failure(error))
            case.success(let distance):
                callBack(.success(distance))
            }
        }
    }
}
