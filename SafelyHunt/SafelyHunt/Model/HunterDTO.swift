//
//  HunterDTO.swift
//  SafelyHunt
//
//  Created by Yoan on 05/08/2022.
//

import Foundation
import FirebaseAuth
struct HunterDTO {
    var displayName: String?
    var areaList: [[String: String]]?
    var latitude: Double?
    var longitude: Double?
    var user: User?
    var date: Int?
}
