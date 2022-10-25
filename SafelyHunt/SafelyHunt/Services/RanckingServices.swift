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

    func getRanking(callBack: @escaping (Result<[Person], Error>) -> Void) {
        let databasePersonInfo = database.child("Database").child("users_list")
        var persons: [Person] = []
        persons .removeAll()

        databasePersonInfo.getData { error, dataSnapshot in
            guard error == nil, let dataSnapshot = dataSnapshot else {
                callBack(.failure(error ?? ServicesError.errorTask))
                return
            }
            guard let data = dataSnapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(ServicesError.listUsersPositions))
                return
            }

            for (index, personID) in data.enumerated() {
                let pathDistanceHunter = personID.childSnapshot(forPath: "distance_traveled")
                let folderDistance = pathDistanceHunter.value as? NSDictionary
                let distance = folderDistance?["Total_distance"]
                let pathUserInfo = personID.childSnapshot(forPath: "info_user")
                let folderInfoUser = pathUserInfo.value as? NSDictionary
                let displayName = folderInfoUser?["name"]
                let email = folderInfoUser?["email"]

                guard let distance = distance as? Double,
                      let displayName = displayName as? String,
                      let email = email as? String else {
                    // if last index
                    if index == data.count-1 {
                        callBack(.success(persons.sorted( by: { $0.totalDistance ?? 0 > $1.totalDistance ?? 0})))
                        return
                    }
                    continue // next index
                }

                let person = Person()
                person.totalDistance = distance
                person.displayName = displayName
                person.email = email
                persons.append(person)

                if index == data.count-1 {
                    callBack(.success(persons.sorted( by: { $0.totalDistance ?? 0 > $1.totalDistance ?? 0})))
                }
            }
        }
    }

}
