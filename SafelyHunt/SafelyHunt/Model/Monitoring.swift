//
//  Monitoring.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import FirebaseAuth
import MapKit

protocol MonitoringProtocol {
    var area: Area {get set}
    var hunter: Hunter? {get set}
    var currentDistance: Double {get set}
    var currentTravel: [CLLocationCoordinate2D] {get set}
    var lastLocation: CLLocation? {get set}
    var firstLocation: CLLocation? {get set}

    func getCurrentTravel(locations: [CLLocation])
    func measureDistanceTravelled(locations: [CLLocation]) -> Double
}

class Monitoring: MonitoringProtocol {
    var area: Area
    var hunter: Hunter?
    var currentDistance: Double = 0.0
    var currentTravel: [CLLocationCoordinate2D] = []
    var lastLocation: CLLocation?
    var firstLocation: CLLocation?

    init(monitoringIsOn: Bool = false, area: Area) {
        self.area = area
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
            if let lastLocation = lastLocation {
                currentDistance += lastLocation.distance(from: location)
            }
        }
        lastLocation = locations.last
        return currentDistance / 1000
    }
}
