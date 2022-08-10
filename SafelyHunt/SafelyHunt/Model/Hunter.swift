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
    var meHunter = HunterDTO()
    var monitoring = Monitoring()
    var area = Area()

    func updatePosition(userPostion: CLLocationCoordinate2D) {
        guard let user = meHunter.user else {
            return
        }
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        let dateToTimeStamp = Int(dateStamp)
        meHunter.latitude = userPostion.latitude
        meHunter.longitude = userPostion.longitude

        FirebaseManagement.shared.insertMyPosition(userPosition: userPostion, user: user, date: dateToTimeStamp)
    }
}


