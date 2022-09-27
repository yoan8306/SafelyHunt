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
    var user: User?
    var date: Int?
    var latitude: Double?
    var longitude: Double?

    init(displayName: String? = nil, user: User? = nil, date: Int? = nil) {
        self.displayName = displayName
        self.user = user
        self.date = date
    }
}
