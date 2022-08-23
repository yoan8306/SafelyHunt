//
//  FirebaseManagement.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//
import UIKit
import Foundation
import FirebaseAuth
import Firebase
import MapKit
import CoreAudio

// MARK: - Sign in
class FirebaseManagement {
    
    // MARK: - properties
    static let shared = FirebaseManagement()
    weak var handle: AuthStateDidChangeListenerHandle?
    private let database = Database.database().reference()
    private let firebaseAuth: FirebaseAuth.Auth = .auth()
    
    private init() {}
    
    // MARK: - Functions
    func checkUserLogged(callBack: @escaping (Result<Bool, Error>) -> Void) {
        handle = firebaseAuth.addStateDidChangeListener { auth, user in
            if ((user) != nil) {
                callBack(.success(true))
            } else {
                callBack(.failure(FirebaseError.signIn))
            }
        }
    }
    
    func removeStateChangeLoggedListen() {
        firebaseAuth.removeStateDidChangeListener(self.handle!)
    }
    
    func createUser(email: String, password: String, displayName: String, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let result = authResult, error == nil else {
                    callBack(.failure(error ?? FirebaseError.createAccountError))
                    return
                }
                callBack(.success(result))
            }
        }
    }
    
    func signInUser(email: String?, password: String?, callBack: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let email = email, let password = password else {
            callBack(.failure(FirebaseError.signIn))
            return
        }
        
        firebaseAuth.signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                guard let authResult = authResult, error == nil else {
                    callBack(.failure(error ?? FirebaseError.signIn))
                    return
                }
                callBack(.success(authResult))
            }
        }
    }
    
    func updateProfile(displayName: String, callBack: @escaping (Result<Auth,Error>) -> Void) {
        let changeRequest = FirebaseAuth.Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { error in
            DispatchQueue.main.async {
                guard error == nil else {
                    callBack(.failure(error ?? FirebaseError.signIn))
                    return
                }
                callBack(.success(self.firebaseAuth))
            }
        })
    }
    
    func resetPassword(email: String, callBack: @escaping (Result<String, Error>) -> Void) {
        firebaseAuth.sendPasswordReset(withEmail: email) { error in
            if error == nil {
                callBack(.success("Email send"))
            }
            callBack(.failure(error ?? FirebaseError.resetPassword))
        }
    }
}
// MARK: - SignUp - Remove Account
extension FirebaseManagement {
    func disconnectCurrentUser() {
        try? firebaseAuth.signOut()
    }
    
    func checkCredential(callback: @escaping (Result<Bool, Error>)-> Void) {
        
    }

    func deleteAccount() {
       let user = firebaseAuth.currentUser
        guard let user = user else {
            return
        }
        database.child("Database").child("users_list").child(user.uid).removeValue()
        database.child("Database").child("position_user").child(user.uid).removeValue()
        Auth.auth().currentUser?.delete()
    }
}

// MARK: - Database Area
extension FirebaseManagement {
    
    func insertArea(user: User, coordinate: [CLLocationCoordinate2D], nameArea: String, date: Int) {
        var index = 0
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")
        
        databaseArea.child(nameArea).setValue([
            "name": nameArea,
            "date": String(date)
        ])
        
        for point in coordinate {
            databaseArea.child(nameArea).child("coordinate").child("coordinate\(index)").setValue([
                "index" : index,
                "latitude": point.latitude,
                "longitude": point.longitude
            ])
            index += 1
        }
    }
    
    func getAreaList(user: User, callBack: @escaping (Result<[[String: String]], Error>) -> Void)  {
        var areaList: [[String: String]] = [[:]]
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")
        
        databaseArea.getData(completion: { error, snapshot in
            guard let snapshot = snapshot, error == nil else {
                callBack(.failure(error ?? FirebaseError.noAreaRecordedFound))
                return
            }
            
            guard let data = snapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(FirebaseError.noAreaRecordedFound))
                return
            }
            
            areaList.removeAll()

            for element in data {
                let list = element.value as? NSDictionary
                let name = list?["name"]
                let date = list?["date"]
                if let name = name as? String, let date = date as? String {
                    areaList.append([name: date])
                }
            }
            callBack(.success(areaList))
        })
    }
    
    func getArea(nameArea: String?, user: User, callBack: @escaping (Result<[CLLocationCoordinate2D], Error>) -> Void) {
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list")
        var coordinateArea: [CLLocationCoordinate2D] = []
        var dictCoordinateArea: [Int: CLLocationCoordinate2D] = [:]
        
        guard let nameArea = nameArea, !nameArea.isEmpty else {
            callBack(.failure(FirebaseError.noAreaRecordedFound))
            return
        }
        
        dictCoordinateArea.removeAll()

        databaseArea.child(nameArea).child("coordinate").getData { error, dataSnapshot in
            guard let snapshot = dataSnapshot, error == nil, let data = snapshot.children.allObjects as? [DataSnapshot] else {
                callBack(.failure(error ?? FirebaseError.noAreaRecordedFound))
                return
            }
            
            //Add all coordinate into dictionary
            for element in data {
                let coordinateElement = element.value as? NSDictionary
                let latitude = coordinateElement?["latitude"]
                let longitude = coordinateElement?["longitude"]
                let index = coordinateElement?["index"]
                if let latitude = latitude as? Double, let longitude = longitude as? Double, let index = index as? Int {
                    dictCoordinateArea[index] = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
            }
            
            if dictCoordinateArea.count <= 0 {
                callBack(.failure(FirebaseError.noAreaRecordedFound))
                return
            }
            
            //sort dictionary by index
            let sortedArray = dictCoordinateArea.sorted( by: { $0.key < $1.key})
            for dict in  0..<dictCoordinateArea.count {
               let list = sortedArray[dict]
                coordinateArea.append(list.value)
            }
            
            callBack(.success(coordinateArea))
        }
    }
    
    func removeArea(name:String, user: User, callBack: @escaping(Result<DatabaseReference, Error>)->Void) {
        let databaseArea = database.child("Database").child("users_list").child(user.uid).child("area_list").child(name)
        databaseArea.removeValue { error, success in
            guard error == nil else {
                callBack(.failure(error ?? FirebaseError.errorDeletingArea))
                return
            }
            callBack(.success(success))
        }
    }
}

// MARK: - UserPosition
extension FirebaseManagement {
    func insertMyPosition(userPosition: CLLocationCoordinate2D, user: User, date: Int) {
        database.child("Database").child("position_user").child(user.uid).setValue([
            "name": user.displayName ?? "no name",
            "date": String(date),
            "latitude": userPosition.latitude,
            "longitude": userPosition.longitude
        ])
    }
    
    func getPositionUsers(callBack: @escaping (Result<[Hunter], Error>)-> Void) {
        let databaseAllPositions = database.child("Database").child("position_user")
        var hunters: [Hunter] = []
        databaseAllPositions.getData { error, snapshot in
            guard error == nil, snapshot != nil else  {
                callBack(.failure(error ?? FirebaseError.noAreaRecordedFound))
                return
            }
            guard let dataSnapshot = snapshot?.children.allObjects else {
                return
            }
            
            guard let data = dataSnapshot as? [DataSnapshot] else {
                return
            }
            guard let userId = self.firebaseAuth.currentUser?.uid else {
                return
            }
            
            for element in data {
                if element.key != userId {
                    let dictElement = element.value as? NSDictionary
                    
                    let name = dictElement?["name"] as? String
                    let latitude = dictElement?["latitude"] as? Double
                    let longitude = dictElement?["longitude"] as? Double
                    let dateString = dictElement?["date"] as? String
                      let date = Int(dateString ?? "0")
                    let hunter = Hunter()
                    hunter.meHunter.displayName = name
                    hunter.meHunter.longitude = longitude
                    hunter.meHunter.latitude = latitude
                    hunter.meHunter.date = date
                    hunters.append(hunter)
                }
            }
            callBack(.success(hunters))
        }
    }
}
