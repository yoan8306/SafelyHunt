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
    var firebaseManagement: FirebaseManaging

    init(listHuntersInRadiusAlert: [Hunter] = [], monitoringIsOn: Bool = false, firebaseManagement: FirebaseManaging = FirebaseManagement.shared) {

        self.listHuntersInRadiusAlert = listHuntersInRadiusAlert
        self.monitoringIsOn = monitoringIsOn
        self.firebaseManagement = firebaseManagement
    }

    func checkUserIsRadiusAlert(hunterSignIn: Hunter?, callback: @escaping(Result<Bool, Error>) -> Void) {
        guard let hunterSignIn = hunterSignIn else {
            callback(.failure(FirebaseError.signIn))
            return
        }

        FirebaseManagement.shared.getPositionUsers { result in
            switch result {
            case .success(let hunters):
                self.addHuntersIntoList(huntersList: hunters, hunterSignIn: hunterSignIn)
                if self.listHuntersInRadiusAlert.count > 0 {
                    callback(.success(true))
                } else {
                    callback(.success(false))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    private func addHuntersIntoList(huntersList: [Hunter], hunterSignIn: Hunter) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }

        let myLatitude = hunterSignIn.latitude ?? 0
        let myLongitude = hunterSignIn.longitude ?? 0
        let myPosition = CLLocation(latitude: myLatitude, longitude: myLongitude)

        FirebaseManagement.shared.insertMyPosition(userPosition: myPosition, user: user, date: Int(Date().timeIntervalSince1970))

        self.listHuntersInRadiusAlert = []

        for hunter in huntersList {
            guard let dateTimeStamp = hunter.date else {
                return
            }

            let lastUpdate = Date(timeIntervalSince1970: TimeInterval(dateTimeStamp))
//            check if user is present less 20 minutes ago
            if lastUpdate.addingTimeInterval(1200) > Date() {
                let latitude = hunter.latitude ?? 0
                let longitude = hunter.longitude ?? 0
                let positionTheOther = CLLocation(latitude: latitude, longitude: longitude)
                let distance = myPosition.distance(from: positionTheOther)
                if Int(distance) < UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert) {
                    self.listHuntersInRadiusAlert.append(hunter)
                }
            }
        }
    }

     func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
       return area.contain(coordinate: positionUser)
    }
}
