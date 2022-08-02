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
// MARK: - Properties
    var areaList: [[String:String]] = [[:]] {
        didSet {
            areaListTableView.reloadData()
        }
    }
    var areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.areaSelected)
    
    
// MARK: - IBOutlet
    @IBOutlet weak var areaListTableView: UITableView!

// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAreaList()
    }
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let mapsStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        
        guard let mapViewController = mapsStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Draw your new area"
        navigationController?.pushViewController(mapViewController, animated: true)
        
    }
    
// MARK: - Private functions
    private func getAreaList() {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }
        FirebaseManagement.shared.getAreaList(user: user) { [weak self] fetchArea in
            switch fetchArea {
            case .success(let listArea):
                self?.areaList = listArea
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension AreaListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AreaCellTableViewCell else {
            let cell = UITableViewCell()
            return cell
        }
    
        cell.configureCell(infoArea: areaList[indexPath.row])
        guard let areaSelected = areaSelected else {
            return cell
        }
        for (key, _) in areaList[indexPath.row] {
            if areaSelected == key {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
}

// MARK: - TableView Delegate
extension AreaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        for (key, _) in areaList[indexPath.row] {
            areaSelected = key
        }
        defaults.set(areaSelected, forKey: UserDefaultKeys.areaSelected)
        transferToMapViewController()
    }
    
    private func transferToMapViewController() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        mapViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
}


