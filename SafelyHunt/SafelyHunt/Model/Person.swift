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
    var uId: String?
    var date: Int?
    var latitude: Double?
    var longitude: Double?
    var totalDistance: Double?
    var email: String?
    var actualPostion: CLLocation? {
        let position = CLLocation(latitude: latitude ?? 0, longitude: longitude ?? 0)
        return position
    }
    var personMode: PersonMode? = PersonMode(rawValue: UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.personMode) ?? "unknown")
//        get { let personModeValue = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.personMode) ?? "unknown"
//            let personMode = PersonMode(rawValue: personModeValue)
//            return personMode
//        }
//        set {
//
//        }
//    }

    init(displayName: String? = nil, uId: String? = nil, date: Int? = nil) {
        self.displayName = displayName
        self.uId = uId
        self.date = date
//        self.personMode = personMode
    }
}
