//
//  FakeDatabase.swift
//  SafelyHuntTests
//
//  Created by Yoan on 26/08/2022.
//

import Foundation
import Firebase

class FakeDatabaseReference {
    var database: DatabaseReference {
        let bundle = Bundle(for: FakeDatabaseReference.self)
        let url = bundle.url(forResource: "DatabaseTest", withExtension: "json")
        let database = Database.database(url: url!.path).reference()
        return database
    }
}
