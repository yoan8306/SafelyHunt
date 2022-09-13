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
    var radiusAlert: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert)
        }
    }
    var areaSelected: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) ?? ""
        }
    }
    var listHuntersInRadiusAlert: [Hunter]

//    in monitoringServices
    var monitoringIsOn: Bool
    var monitoringServices: MonitoringServicesProtocol

    var currentDistance: Double = 0.0
    var currentTravel: [CLLocationCoordinate2D] = []
    private var lastLocation: CLLocation!
    private var firstLocation: CLLocation?

    init(listHuntersInRadiusAlert: [Hunter] = [], monitoringIsOn: Bool = false, monitoringServices: MonitoringServicesProtocol = MonitoringServices.shared) {
        self.listHuntersInRadiusAlert = listHuntersInRadiusAlert
        self.monitoringIsOn = monitoringIsOn
        self.monitoringServices = monitoringServices
    }

//    func updatePositionTravelled([CLLocation]) {
//        
//    }

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

//    in services
    func checkUserIsRadiusAlert(hunterSignIn: Hunter?, callback: @escaping(Result<Bool, Error>) -> Void) {
        guard let hunterSignIn = hunterSignIn else {
            callback(.failure(ServicesError.signIn))
            return
        }

        monitoringServices.getPositionUsers { result in
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

    func checkUserIsAlwayInArea(area: MKPolygon, positionUser: CLLocationCoordinate2D) -> Bool {
      return area.contain(coordinate: positionUser)
   }

    func insertMyDistanceTraveled() {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        monitoringServices.insertDistanceTraveled(user: user, distance: currentDistance)
        currentDistance = 0
        currentTravel = []
        lastLocation = nil
        firstLocation = nil
    }

    func getTotalDistanceTraveled(callBack: @escaping (Result<Double, Error>) -> Void ) {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
       monitoringServices.getDistanceTraveled(user: user) { result in
            switch result {
            case .failure(let error):
                callBack(.failure(error))
            case.success(let distance):
                callBack(.success(distance))
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

        monitoringServices.insertMyPosition(userPosition: myPosition, user: user, date: Int(Date().timeIntervalSince1970))

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

}
