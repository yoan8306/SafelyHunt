//
//  SettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func disonnectButton() {
        FirebaseManagement.shared.disconnectCurrentUser()
        
    }

}
