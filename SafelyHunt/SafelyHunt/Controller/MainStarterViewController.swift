//
//  MainStarterViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class MainStarterViewController: UIViewController {
    
    let mainStarter = MainStarterData().mainStarter
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
