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
// MARK: - Properties
    var monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()))
    var hunter = Hunter()

// MARK: - IBOutlet
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var pseudonymeLabel: UILabel!

// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getTotalDistance()
        setLabel()
    }

    // MARK: - Private functions
    /// Get distance from database
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

    /// set label user information
    private func setLabel() {
        mailLabel.text = FirebaseAuth.Auth.auth().currentUser?.email
        pseudonymeLabel.text = FirebaseAuth.Auth.auth().currentUser?.displayName
    }
}
