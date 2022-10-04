//
//  ProfileViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 02/09/2022.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {

    var monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()))
    var hunter = Hunter()

    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var pseudonymeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        pseudonymeLabel.text = FirebaseAuth.Auth.auth().currentUser?.displayName
        getTotalDistance()
        mailLabel.text = FirebaseAuth.Auth.auth().currentUser?.email
    }

    private func getTotalDistance() {
        monitoringServices.getTotalDistanceTraveled { [weak self] result in
            switch result {
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            case .success(let distance):
                self?.totalDistanceLabel.text = String(format: "%.2f", distance / 1000) + " Km"
            }
        }
    }
}
