//
//  MainStarterData.swift
//  SafelyHunt
//
//  Created by Yoan on 08/07/2022.
//

import Foundation

/// List main
class MainData {
   static let mainStarter = [
    "Select your hunting area".localized(tableName: "LocalizableMainData"),
    "Define your radius alert".localized(tableName: "LocalizableMainData")
   ]
   static let pickerMapType = ["Standard", "Muted standard", "Sattelite"]
   static let mainSettings = [
    "Profile",
    "Ranking".localized(tableName: "LocalizableMainData"),
    "Activate location".localized(tableName: "LocalizableMainData"),
    "Show tutorial".localized(tableName: "LocalizableMainData"),
    "Account".localized(tableName: "LocalizableMainData")
   ]
    private init() {}
}
