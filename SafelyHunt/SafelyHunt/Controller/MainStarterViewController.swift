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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = user else {
            return
        }
        
        let dateNow = Date()
        let dateStamp: TimeInterval = dateNow.timeIntervalSince1970
        var pointList: [CLLocationCoordinate2D] = []
        for _ in 0...5 {
            let latitude = Double.random(in: 0.0..<200)
            let longitude = Double.random(in: 0.0..<200)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            pointList.append(coordinate)
        }
        
        FirebaseManagement.shared.insertArea(user: user, coordinate: pointList, nameArea: "SecondZone", date: Int(dateStamp))
    }
}

extension MainStarterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStarter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellStarter", for: indexPath)
        let title = mainStarter[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            switch indexPath.row {
            case 0:
                content.secondaryText = UserDefaultKeys.areaSelected
            case 1:
                content.secondaryText = "\(UserDefaultKeys.radiusAlert) m"
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
        return cell
    }
}
