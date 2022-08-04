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
    }
    
    static var areaSelected: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.areaSelected) ?? "No Selection"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.areaSelected)
        }
    }
    
    static var radiusAlert: Float {
        get {
            return UserDefaults.standard.float(forKey: Keys.radiusAlert)
        }
        set {
            UserDefaults.standard.float(forKey: Keys.radiusAlert)
        }
    }
    
    
}
