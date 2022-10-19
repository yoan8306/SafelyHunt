//
//  RankingViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 19/10/2022.
//

import UIKit

class RankingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        RankingService.shared.getRanking { success in
            switch success {
            case .success(let hunters):
                print(hunters)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        // Do any additional setup after loading the view.
    }

}

extension RankingViewController: UITableViewDelegate {
    
}
extension RankingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath)
        return cell
    }
    
    
}
