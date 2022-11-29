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
    var person = Person()

// MARK: - IBOutlet
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var pseudonymeLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var stackViewContener: UIStackView!

// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfoProfile()
        stackViewContener.layer.cornerRadius = 8
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Private functions
    private func getInfoProfile() {
        UserServices.shared.getProfileUser { [weak self] result in
            switch result {
            case .success(let person):
                self?.setLabel(person: person)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    /// set label user information
    private func setLabel(person: Person) {
        mailLabel.text = person.email
        pseudonymeLabel.text = person.displayName
        pointsLabel.text = String(format: "%.2f", person.totalPoints ?? 0)
        totalDistanceLabel.text = String(format: "%.2f", (person.totalDistance ?? 0) / 1000) + " Km"
    }
}
