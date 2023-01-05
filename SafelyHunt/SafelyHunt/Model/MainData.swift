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
    static let informations = [
    "Your level".localized(tableName: "LocalizableMainData"),
    "Hunting period".localized(tableName: "LocalizableMainData")
    ]
   static let pickerMapType = ["Standard", "Muted standard", "Satellite"]
   static let mainSettings = [
    "Profile",
    "Hunt / Walker".localized(tableName: "LocalizableMainData"),
    "Ranking".localized(tableName: "LocalizableMainData"),
    "Activate location".localized(tableName: "LocalizableMainData"),
    "Show tutorial".localized(tableName: "LocalizableMainData"),
    "Change alerts sound".localized(tableName: "LocalizableMainData"),
    "Account".localized(tableName: "LocalizableMainData")
   ]
    private init() {}
}
