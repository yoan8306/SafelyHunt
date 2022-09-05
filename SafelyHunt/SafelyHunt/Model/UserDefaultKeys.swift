//
//  UserDefaultKeys.swift
//  SafelyHunt
//
//  Created by Yoan on 08/07/2022.
//

import Foundation

class UserDefaultKeys {
    struct Keys {
        static let areaSelected = "AreaSelected"
        static let radiusAlert = "Radius alert"
        static let allowsNotificationRadiusAlert = "Notification radius alert"
    }

    static var areaSelected: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.areaSelected) ?? "No Selection"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.areaSelected)
        }
    }

    static var radiusAlert: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.radiusAlert)
        }
        set {
            UserDefaults.standard.integer(forKey: Keys.radiusAlert)
        }
    }

    static var allowsNotificationRadiusAlert: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.allowsNotificationRadiusAlert)
        }
        set {
            UserDefaults.standard.bool(forKey: Keys.allowsNotificationRadiusAlert)
        }
    }
}
