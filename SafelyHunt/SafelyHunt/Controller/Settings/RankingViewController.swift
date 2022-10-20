//
//  RankingViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 19/10/2022.
//

import UIKit
import FirebaseAuth

class RankingViewController: UIViewController {
    var rankingHunters: [Hunter] = []

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yourPositionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideShowView(shown: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRanking()
    }

    private func getRanking() {
        hideShowView(shown: false)
        RankingService.shared.getRanking { [weak self] success in
            switch success {
            case .success(let hunters):
                self?.rankingHunters = hunters
                self?.tableView.reloadData()
                self?.hideShowView(shown: true)
            case .failure(let error):
                self?.hideShowView(shown: false)
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }

    private func hideShowView(shown: Bool) {
        tableView.isHidden = !shown
        activityIndicator.isHidden = shown
        yourPositionLabel.isHidden = !shown
    }

}

extension RankingViewController: UITableViewDelegate {

}
extension RankingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingHunters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath)
        let hunter = rankingHunters[indexPath.row]

        guard let displayname = hunter.displayName, let totalDistance = hunter.totalDistance else {
            return cell
        }

        let stringTotalDistance = String(format: "%.2f", totalDistance / 1000)
        if hunter.email! == FirebaseAuth.Auth.auth().currentUser?.email {
            yourPositionLabel.text = "Your are at \(indexPath.row + 1) \(displayname) \(stringTotalDistance) km"
        }

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = "\(indexPath.row + 1)/  \(String(describing: displayname))"
            content.secondaryText = "\(stringTotalDistance) km"

            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text =  "\(indexPath.row + 1) - \(String(describing: displayname))"
            cell.detailTextLabel?.text =  "\(stringTotalDistance) km"
        }

        return cell
    }
}
