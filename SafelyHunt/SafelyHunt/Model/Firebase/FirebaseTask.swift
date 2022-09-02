//
//  FirebaseTask.swift
//  SafelyHunt
//
//  Created by Yoan on 25/08/2022.
//

import Foundation
import FirebaseAuth
import Firebase

// MARK: - Protocole for test FirebaseTask
protocol FirebaseTaskProtocol {
    func getData(databaseReference: DatabaseReference, callBack: @escaping (Result<DataSnapshot, Error>) -> Void)
}

class FirebaseTask: FirebaseTaskProtocol {
    static let shared = FirebaseTask()
    private init() {}
    
    func getData(databaseReference: DatabaseReference, callBack: @escaping (Result<DataSnapshot, Error>) -> Void) {
        databaseReference.getData { error, dataSnapShot in
            guard let dataSnapShot = dataSnapShot else {
                callBack(.failure(error ?? FirebaseError.errorTask))
                return
            }
            callBack(.success(dataSnapShot))
        }
    }
}
