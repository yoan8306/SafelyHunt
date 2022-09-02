//
//  FirebaseTaskMock.swift
//  SafelyHuntTests
//
//  Created by Yoan on 25/08/2022.
//

import Foundation
import Firebase
@testable import SafelyHunt

class FirebaseTaskMock: FirebaseTaskProtocol {
    var dataSnapshot: DataSnapshot?
    var error: Error?

    func getData(databaseReference: DatabaseReference, callBack: @escaping (Result<DataSnapshot, Error>) -> Void) {
        if let dataSnapshot = dataSnapshot {
            callBack(.success(dataSnapshot))
        } else if let error = error {
            callBack(.failure(error))
        }
    }
}
