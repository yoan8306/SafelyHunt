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
    var name: String?
    var date: String?
    var city: String?
    var coordinatesPoints: [CLLocationCoordinate2D] = []
    var coordinateTravel: [CLLocationCoordinate2D] = []

    init(coordinatesPoints: [CLLocationCoordinate2D] = [], coordinateTravel: [CLLocationCoordinate2D] = []) {
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
}
