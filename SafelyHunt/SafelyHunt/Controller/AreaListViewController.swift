//
//  AreaListViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 25/07/2022.
//

import UIKit
import AVFoundation
import FirebaseAuth
import SwiftUI

class AreaListViewController: UIViewController {
    // MARK: - Properties
    var hunter = Hunter()
    @objc var refreshControl = UIRefreshControl()
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var areaListTableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        areaListTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAreaList()
    }
    
    // MARK: - IBAction
    @objc func refreshTable() {
        getAreaList()
    }
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let mapsStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        
        guard let mapViewController = mapsStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        
        mapViewController.hunter = hunter
        mapViewController.mapMode = .editingArea
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Editing area"
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    
    // MARK: - Private functions
    private func getAreaList() {
        activityIndicator.isHidden = false
        guard let user = hunter.meHunter.user else {
            return
        }
        
        FirebaseManagement.shared.getAreaList(user: user) { [weak self] fetchArea in
            switch fetchArea {
            case .success(let listArea):
                self?.hunter.meHunter.areaList = listArea
                self?.areaListTableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.isHidden = true
                self?.initializeBackgroundTableView()
                
            case .failure(let error):
                self?.presentAlertError(alertMessage: error.localizedDescription)
                self?.activityIndicator.isHidden = true
            }
        }
    }
    
    private func initializeBackgroundTableView() {
        if hunter.meHunter.areaList?.count == 0 {
            let backgroundImage = UIImage(named: "listVoid")
            let image = UIImageView(image: backgroundImage)
            image.contentMode = .scaleAspectFit
            areaListTableView.backgroundView = image
        } else {
            areaListTableView.backgroundView = nil
        }
    }
}

// MARK: - TableViewDataSource
extension AreaListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hunter.meHunter.areaList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellSelected = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AreaCellTableViewCell,
              let areaList = hunter.meHunter.areaList else {
            return UITableViewCell()
        }
        
        for (key, _) in areaList[indexPath.row] {
            if hunter.area.areaSelected == key {
                cellSelected = true
            }else {
                cellSelected = false
            }
        }
        
        cell.configureCell(infoArea: areaList[indexPath.row], cellSelected: cellSelected)
        return cell
    }
}

// MARK: - TableView Delegate
extension AreaListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var newAreaSelected = ""
        guard let areaList = hunter.meHunter.areaList else {
            return
        }
        
        for (key, _) in areaList[indexPath.row] {
            newAreaSelected = key
        }
        
        UserDefaults.standard.set(newAreaSelected, forKey: UserDefaultKeys.Keys.areaSelected)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let user = hunter.meHunter.user else {
            return
        }
        
        if editingStyle == .delete {
            askDelete(indexPath: indexPath, user: user)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var nameArea = ""
        guard let areaList = hunter.meHunter.areaList else {
            return
        }
        
        for (key,_) in areaList[indexPath.row] {
            nameArea = key
        }
        
        transferToMapViewController(nameAreaSelected: nameArea)
    }
    
    // MARK: - private func tableView
    private func askDelete (indexPath: IndexPath, user: User) {
        let alertVC = UIAlertController(title: "Delete area", message: "Are you sure you want delete this area", preferredStyle: .actionSheet)
        let deletingAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteArea(indexPath, user)
        }
        let dismiss = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertVC.addAction(deletingAction)
        alertVC.addAction(dismiss)
        present(alertVC, animated: true, completion: nil)
    }
    
    /// delete area selected
    /// - Parameters:
    ///   - indexPath: cell area detect
    ///   - user: user signIn
    private func deleteArea(_ indexPath: IndexPath, _ user: User) {
        var areaName = ""
        guard let areaList = hunter.meHunter.areaList else {
            return
        }
        
        for (key,_) in areaList[indexPath.row] {
            areaName = key
        }
        
        FirebaseManagement.shared.removeArea(name: areaName, user: user) { [weak self] result in
            switch result {
            case .success(_):
                self?.getAreaList()
                self?.presentNativeAlertSuccess(alertMessage: "Area Deleting")
                UserDefaults.standard.set("", forKey: UserDefaultKeys.Keys.areaSelected)
            case.failure(let error):
                self?.getAreaList()
                self?.presentAlertError(alertTitle: "Error", alertMessage: error.localizedDescription, buttonTitle: "Dismiss", alertStyle: .cancel)
            }
        }
    }
    
    private func transferToMapViewController(nameAreaSelected: String) {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        mapViewController.hunter = hunter
        mapViewController.mapMode = .editingArea
        mapViewController.nameAreaSelected = nameAreaSelected
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Editing area"
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}


