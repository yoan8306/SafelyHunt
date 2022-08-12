//
//  MainStarterViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit
import FirebaseAuth
import MapKit

class MainStarterViewController: UIViewController {
    let user = FirebaseAuth.Auth.auth().currentUser
    let mainStarter = MainStarterData().mainStarter
    var hunter = Hunter()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hunter.meHunter.user = user
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func startMonitoringButton(_ sender: UIButton) {
        transferToMapViewController()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func transferToMapViewController() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController, let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) else {
            return
        }
        
        mapViewController.hunter = hunter
        mapViewController.mapMode = .monitoring
        mapViewController.nameAreaSelected = areaSelected
        mapViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    
}

extension MainStarterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStarter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellStarter", for: indexPath)
        let title = mainStarter[indexPath.row]
        
        configureCell(cell, title, indexPath)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, _ title: String, _ indexPath: IndexPath) {
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            switch indexPath.row {
            case 0:
                content.secondaryText = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)
            case 1:
                content.secondaryText = "\(UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.radiusAlert) ?? "0") m"
            default:
                break
            }
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = UserDefaultKeys.Keys.areaSelected
            case 1:
                cell.detailTextLabel?.text = "\(UserDefaultKeys.Keys.radiusAlert) m"
            default:
                break
            }
        }
    }
    
}

extension MainStarterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            transferToAreaListViewController()
        case 1:
            transferToMapForSetRadiusAlert()
        default:
            break
        }
    }
    
    private func transferToAreaListViewController() {
        let areaListStoryboard = UIStoryboard(name: "AreasList", bundle: nil)
        
        guard let areaListViewController = areaListStoryboard.instantiateViewController(withIdentifier: "AreasList") as? AreaListViewController else {
            return
        }
        areaListViewController.hunter.meHunter.user = hunter.meHunter.user
        areaListViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(areaListViewController, animated: true)
    }
    
    private func transferToMapForSetRadiusAlert() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        mapViewController.mapMode = .editingRadius
        mapViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
