//
//  FakeResponseDataSnapshot.swift
//  SafelyHuntTests
//
//  Created by Yoan on 25/08/2022.
//

import Foundation
import Firebase

class FakeResponseDataSnapshot {
    var dataSnapshot: DataSnapshot {
        let bundle = Bundle(for: FakeResponseDataSnapshot.self)
        let url = bundle.url(forResource: "RecipesList", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let dataSnapshot = data as? DataSnapshot
        return data
    }
}
