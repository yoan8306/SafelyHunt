//
//  RankingViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 19/10/2022.
//

import UIKit
import FirebaseAuth

class RankingViewController: UIViewController {
    var rankingPersons: [Person] = []

    // MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yourPositionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showView(shown: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRanking()
    }

    // MARK: - Privates functions
    private func getRanking() {
        showView(shown: false)
        RankingService.shared.getRanking { [weak self] success in
            switch success {
            case .success(let hunters):
                self?.rankingPersons = hunters
                self?.tableView.reloadData()
                self?.showView(shown: true)
            case .failure(let error):
                self?.showView(shown: false)
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }

    private func showView(shown: Bool) {
        tableView.isHidden = !shown
        activityIndicator.isHidden = shown
        yourPositionLabel.isHidden = !shown
    }
}

// MARK: - UITableView DataSource
extension RankingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingPersons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath)
        let person = rankingPersons[indexPath.row]

        guard let displayName = person.displayName, let totalPoints = person.totalPoints else {
            return cell
        }
        var content = cell.defaultContentConfiguration()
        let stringTotalPoints = String(format: "%.2f", totalPoints)

        if person.email! == FirebaseAuth.Auth.auth().currentUser?.email {
            yourPositionLabel.text = "Your are in the ".localized(tableName: "LocalizableAccountSetting") + "\(indexPath.row + 1)" + " place of ranking with ".localized(tableName: "LocalizableAccountSetting") + "\(stringTotalPoints)"
            cell.backgroundColor = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        }

        content.text = "\(indexPath.row + 1)/  \(String(describing: displayName))"
        content.secondaryText = "\(stringTotalPoints)"
        content.textProperties.color = .black
        content.secondaryTextProperties.color = .black
        cell.contentConfiguration = content

        return cell
    }
}
