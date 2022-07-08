//
//  UserDefaultKeys.swift
//  SafelyHunt
//
//  Created by Yoan on 08/07/2022.
//

import Foundation

class UserDefaultKeys {
    private struct Keys {
        static let areaSelected: String = "No selection"
    }
    
    static var areaSelected: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.areaSelected) ?? "No Selection"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.areaSelected)
        }
    }
    
    
}
