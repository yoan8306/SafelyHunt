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
    var listHuntersInRadiusAlert: [Hunter] = []
    var monitoringIsOn = false
    var alerted = false
    
    func CheckUserIsRadiusAlert(hunterSignIn: Hunter?, callback: @escaping(Result<Bool, Error>) -> Void) {
        guard let hunterSignIn = hunterSignIn else {
            callback(.failure(FirebaseError.signIn))
            return
        }

        FirebaseManagement.shared.getPositionUsers { result in
            switch result {
            case .success(let hunters):
                self.addHuntersIntoList(huntersList: hunters, hunterSignIn: hunterSignIn)
                self.giveAlertHuntersInRadiusAlert()
                callback(.success(true))
                
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    private func addHuntersIntoList(huntersList: [Hunter], hunterSignIn: Hunter) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        let myLatitude = hunterSignIn.meHunter.latitude ?? 0
        let myLongitude = hunterSignIn.meHunter.longitude ?? 0
        let myPosition = CLLocation(latitude: myLatitude, longitude: myLongitude)
        
        FirebaseManagement.shared.insertMyPosition(userPosition: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude), user: user , date: Int(Date().timeIntervalSince1970))
        
        self.listHuntersInRadiusAlert = []

        for hunter in huntersList {
            guard let dateTimeStamp = hunter.meHunter.date else {
                return
            }
            let lastUpdate = Date(timeIntervalSince1970: TimeInterval(dateTimeStamp))
//            check if user is present less 20 minutes ago
            if lastUpdate.addingTimeInterval(1200) > Date() {
                let latitude = hunter.meHunter.latitude ?? 0
                let longitude = hunter.meHunter.longitude ?? 0
                let positionTheOther = CLLocation(latitude: latitude, longitude: longitude)
                let distance = myPosition.distance(from: positionTheOther)
                if Int(distance) < UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert) {
                    self.listHuntersInRadiusAlert.append(hunter)
                }
            }
        }
    }

    private func giveAlertHuntersInRadiusAlert() {
        if listHuntersInRadiusAlert.count > 0, monitoringIsOn {
            alerted = true
        }
        alerted = false
    }
    
     func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
       return area.contain(coordinate: positionUser)
    }
    
    private func numberDayBetween(from: Date, to : Date) -> Int {
        let cal = Calendar.current
        let numbersDays = cal.dateComponents([.day], from: from, to: to)
        guard let numbersDays = numbersDays.day else {
            return 0
        }
        return numbersDays
    }

}
