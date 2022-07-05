//
//  ViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 28/06/2022.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var ref: DatabaseReference!
    let database = "MyDataBase"
    let userList = "Users"
    var startStop = true
    
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var textViewList: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        observeDataBase()
    }
    
    @IBAction func StopStartObserverButton() {
        startStop = !startStop
        if startStop {
            ref.child(database).child(userList).removeAllObservers()
        } else {
            observeDataBase()
        }
    }
    

    @IBAction func addClickButton() {
        guard let name = textFieldName.text else {
            return
        }
        
        ref.child(database).child(userList).child(name).setValue(name)
        ref.child(database).child(userList).child(name).child("latitude").setValue("34")
        ref.child(database).child(userList).child(name).child("Longitude").setValue("34")
        textFieldName.text = ""
    }
    
    func observeDataBase() {
        ref.child(database).child(userList).observe(.value) {snapShot in
            self.textViewList.text = ""
            
            if let snapShot = snapShot.children.allObjects as? [DataSnapshot] {
                
                for element in snapShot {
                    if let singleName  = element.value as? String {
                        self.textViewList.text = self.textViewList.text + singleName + "\n"
                    }
                }
            }
        }
    }
    
}

