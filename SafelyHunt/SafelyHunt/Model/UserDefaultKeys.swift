//
//  UserDefaultKeys.swift
//  SafelyHunt
//
//  Created by Yoan on 08/07/2022.
//

import Foundation

class UserDefaultKeys {
    private struct Keys {
        static let areaSelected = "AreaSelected"
        static let radiusAlert = "RadiusAlert"
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
    
    
}
