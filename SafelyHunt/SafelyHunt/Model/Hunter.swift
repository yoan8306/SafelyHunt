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
    var displayName: String?
    var areaList: [[String: String]]?
    var latitude: Double?
    var longitude: Double?
    var user: User?
    var date: Int?
    var monitoring: Monitoring // delete
    var area: Area

    init(displayName: String? = nil, areaList: [[String: String]]? = nil, latitude: Double? = nil, longitude: Double? = nil, user: User? = nil, date: Int? = nil, monitoring: Monitoring = Monitoring(), area: Area = Area()) {
        self.displayName = displayName
        self.areaList = areaList
        self.latitude = latitude
        self.longitude = longitude
        self.user = user
        self.date = date
        self.monitoring = monitoring // delete
        self.area = area
    }
}
