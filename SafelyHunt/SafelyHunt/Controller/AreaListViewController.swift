//
//  AreaListViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 25/07/2022.
//

import UIKit
import AVFoundation
import FirebaseAuth

class AreaListViewController: UIViewController {
    var areaList: [[String:String]] = [[:]] {
        didSet {
            areaListTableView.reloadData()
        }
    }
    
    @IBOutlet weak var areaListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        FirebaseManagement.shared.getAreaList(user: user) { fetchArea in
            switch fetchArea {
            case .success(let listArea):
                self.areaList = listArea
            case .failure(let error):
                self.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }

}

extension AreaListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nameArea = areaList[indexPath.row].keys.description
        let dateCreate = areaList[indexPath.row].values.description
        cell.textLabel?.text = nameArea
        cell.detailTextLabel?.text = dateCreate
        return cell
    }
}

extension AreaListViewController: UITableViewDelegate {
    
}


