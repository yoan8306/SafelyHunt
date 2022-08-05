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
    func updatePosition(user: User, userPostion: CLLocationCoordinate2D) {
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        let dateToTimeStamp = Int(dateStamp)
        
        FirebaseManagement.shared.insertMyPosition(userPosition: userPostion, user: user, date: dateToTimeStamp)
    }
    
    func getPosition() {
        FirebaseManagement.shared.getPositionUser { _ in
            
        }
    }
}
