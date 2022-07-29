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
    var coordinateArea : [CLLocationCoordinate2D] = []
    
    
    func createPolyLine() -> MKOverlay {
     MKPolyline(coordinates: coordinateArea, count: coordinateArea.count)
    }
    
    func createPolygon() -> MKOverlay {
        MKPolygon(coordinates: coordinateArea, count: coordinateArea.count)
    }
    
    func transfertAreaToFireBase(nameArea: String?) {
        guard let user = FirebaseAuth.Auth.auth().currentUser, let nameArea = nameArea else {
            return
        }
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        let dateToTimeStamp = Int(dateStamp)
        
        FirebaseManagement.shared.insertArea(user: user, coordinate: coordinateArea, nameArea: nameArea, date: dateToTimeStamp)
    }
    
}
