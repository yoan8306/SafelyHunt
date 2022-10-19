//
//  RankingViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 19/10/2022.
//

import UIKit

class RankingViewController: UIViewController {
    var rankingHunters: [Hunter] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRanking()
    }

    private func getRanking() {
        RankingService.shared.getRanking { [weak self] success in
            switch success {
            case .success(let hunters):
                self?.rankingHunters = hunters
                self?.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = "\(indexPath.row) - \(String(describing: hunter.displayName!))"
            content.secondaryText = String(describing: hunter.totalDistance!)

            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text =  "\(indexPath.row) - \(String(describing: hunter.displayName!))"
            cell.detailTextLabel?.text =  String(describing: hunter.totalDistance!)

        }

        return cell
    }

}
