//
//  RanckingServices.swift
//  SafelyHunt
//
//  Created by Yoan on 19/10/2022.
//

import Foundation
import Firebase
import FirebaseAuth

class RankingService {
    static let shared = RankingService()
    private let database = Database.database().reference()
    private let firebaseAuth = FirebaseAuth.Auth.auth()

    private init() {}

    func getRanking(callBack: @escaping (Result<[Hunter], Error>) -> Void) {
        let databaseHunterInfo = database.child("Database").child("users_list")
        var hunters: [Hunter] = []
        hunters .removeAll()

        databaseHunterInfo.getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.errorTask))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.listUsersPositions))
                return
            }

            for (index, hunterId) in data.enumerated() {
                let pathDistanceHunter = hunterId.childSnapshot(forPath: "distance_traveled")
                let folderDistance = pathDistanceHunter.value as? NSDictionary
                let distance = folderDistance?["Total_distance"]
                let pathUserInfo = hunterId.childSnapshot(forPath: "info_user")
                let folderInfoUser = pathUserInfo.value as? NSDictionary
                let displayName = folderInfoUser?["name"]
                let email = folderInfoUser?["email"]

                guard let distance = distance as? Double,
                      let displayName = displayName as? String,
                      let email = email as? String else {
                    if index == data.count-1 {
                        callBack(.success(hunters.sorted( by: { $0.totalDistance ?? 0 > $1.totalDistance ?? 0})))
                        return
                    }
                    continue}

                let hunter = Hunter()
                hunter.totalDistance = distance
                hunter.displayName = displayName
                hunter.email = email
                hunters.append(hunter)

                if index == data.count-1 {
                    callBack(.success(hunters.sorted( by: { $0.totalDistance ?? 0 > $1.totalDistance ?? 0})))
                }
            }
        }
    }

}
