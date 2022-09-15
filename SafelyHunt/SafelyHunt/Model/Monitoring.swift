//
//  Monitoring.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import FirebaseAuth
import MapKit

class Monitoring {
    var area = Area()
    var hunter = Hunter()
    var listHuntersInRadiusAlert: [Hunter]

    //    in monitoringServices
    var currentDistance: Double = 0.0
    var currentTravel: [CLLocationCoordinate2D] = []
    var lastLocation: CLLocation!
    var firstLocation: CLLocation?

    init(listHuntersInRadiusAlert: [Hunter] = [], monitoringIsOn: Bool = false) {
        self.listHuntersInRadiusAlert = listHuntersInRadiusAlert
    }

    func getCurrentTravel(locations: [CLLocation]) {
        for location in locations {
            currentTravel.append(location.coordinate)
        }
    }

    func measureDistanceTravelled(locations: [CLLocation]) -> Double {
        if firstLocation == nil {
            firstLocation = locations.first
        } else if let location = locations.last {
            currentDistance += lastLocation.distance(from: location)
        }
        lastLocation = locations.last
        return currentDistance / 1000
    }
}
