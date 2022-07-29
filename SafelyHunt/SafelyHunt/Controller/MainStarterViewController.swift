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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = user else {
                  return
              }
              
//              let dateNow = Date()
//              let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
//              let dateToTimeStamp = Int(dateStamp)
//              var coordinate: [CLLocationCoordinate2D] = []
//              for _ in 0...5 {
//                  let latitude: Double = .random(in: 0...200)
//                  let longitude: Double = .random(in: 0...200)
//                  coordinate.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//              }
//
//              FirebaseManagement.shared.insertArea(user: user, coordinate: coordinate, nameArea: "MyFirstZone", date: dateToTimeStamp)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
                content.secondaryText = UserDefaults.standard.string(forKey: UserDefaultKeys.areaSelected)
            case 1:
                content.secondaryText = "\(UserDefaults.standard.string(forKey: String(UserDefaultKeys.radiusAlert)) ?? "0") m"
            default:
                break
            }
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = UserDefaultKeys.areaSelected
            case 1:
                cell.detailTextLabel?.text = "\(UserDefaultKeys.radiusAlert) m"
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
            transfertToAreaListViewController()
        default:
            break
        }
    }
    
    private func transfertToAreaListViewController() {
        let areaListStoryboard = UIStoryboard(name: "AreasList", bundle: nil)
        
        guard let areaListViewController = areaListStoryboard.instantiateViewController(withIdentifier: "AreasList") as? AreaListViewController else {
            return
        }
        
        areaListViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(areaListViewController, animated: true)
    }
    
}
