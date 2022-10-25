//
//  Person.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import FirebaseAuth
import MapKit

class Person {
    var displayName: String?
    var user: User?
    var date: Int?
    var latitude: Double?
    var longitude: Double?
    var totalDistance: Double?
    var email: String?
    var actualPostion: CLLocation? {
        let position = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        return position
    }
    var personMode: PersonMode?

    init(displayName: String? = nil, user: User? = nil, date: Int? = nil, personMode: PersonMode = .hunter) {
        self.displayName = displayName
        self.user = user
        self.date = date
        self.personMode = personMode
    }
}
