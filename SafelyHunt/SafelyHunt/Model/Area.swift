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
    var coordinatesPoints : [CLLocationCoordinate2D] = []
    var coordinateTravel: [CLLocationCoordinate2D] = []
    
    func createPolyLineTravel() -> MKOverlay {
        MKPolyline(coordinates: coordinateTravel, count: coordinateTravel.count)
    }
    
    func createPolyLine() -> MKOverlay {
     MKPolyline(coordinates: coordinatesPoints, count: coordinatesPoints.count)
    }
    
    func createPolygon() -> MKOverlay {
        MKPolygon(coordinates: coordinatesPoints, count: coordinatesPoints.count)
    }
    
    func createCircle(userPosition: CLLocationCoordinate2D, radius:CLLocationDistance) -> MKOverlay {
        MKCircle(center: userPosition, radius: radius)
    }
    
    func transfertAreaToFireBase(nameArea: String?) {
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        let dateToTimeStamp = Int(dateStamp)

        guard let user = FirebaseAuth.Auth.auth().currentUser, let nameArea = nameArea else {
            return
        }
       
        FirebaseManagement.shared.insertArea(user: user, coordinate: coordinatesPoints, nameArea: nameArea, date: dateToTimeStamp)
    }
}
