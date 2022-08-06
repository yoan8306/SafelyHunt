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
    var hunterInRadiusAlert : [Hunter] = []
    var others: [Hunter] = []
    var monitoring = false
    
    func myAreaList() ->[[String:String]] {
        guard let areaList = meHunter.areaList else {
            return [[:]]
        }
        return areaList
    }
    
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
    
     func getHuntersInRadiusAlert() {
        hunterInRadiusAlert = []
        let radiusAlert = UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert)
        for hunter in others {
            let latitude = hunter.meHunter.latitude ?? 0
            let longitude = hunter.meHunter.longitude ?? 0
            let positionTheOther = CLLocation(latitude: latitude, longitude: longitude)
            let myLatitude = meHunter.latitude ?? 0
            let myLongitude = meHunter.longitude ?? 0
            let myPosition = CLLocation(latitude: myLatitude, longitude: myLongitude)
            let distance = myPosition.distance(from: positionTheOther)
            if Int(distance) < radiusAlert {
                hunterInRadiusAlert.append(hunter)
            }
        }
    }
    
    
    
}


