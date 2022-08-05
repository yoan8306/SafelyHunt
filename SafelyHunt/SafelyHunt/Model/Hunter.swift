//
//  UserHunter.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import FirebaseAuth

class Hunter {
   var meHunter = HunterDTO()
    var others: [Hunter] = []
    
    func myAreaList() ->[[String:String]] {
        guard let areaList = meHunter.areaList else {
            return [[:]]
        }
        return areaList
    }
}


