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

        databaseHunterInfo.getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.errorTask))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.listUsersPositions))
                return
            }

            for hunterId in data {
                let pathDistanceHunter = hunterId.childSnapshot(forPath: "distance_traveled")
                let valueDistance = pathDistanceHunter.value as? NSDictionary
                let distance = valueDistance?["Total_distance"]
                print(distance)
                guard let distance = distance as? Double else {return}

                let hunter = Hunter()
                hunter.totalDistance = distance
            }
        }
    }

}
