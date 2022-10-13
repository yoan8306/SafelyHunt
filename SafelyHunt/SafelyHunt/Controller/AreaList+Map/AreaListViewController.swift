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
    var listArea: [Area] = []
    var refreshControl = UIRefreshControl()

    // MARK: - IBOutlet
    @IBOutlet weak var areaListTableView: UITableView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.isTranslucent = true
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        areaListTableView.addSubview(refreshControl)
        initializeBackgroundTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl.beginRefreshing()
        getAreaList()
    }

    // MARK: - IBAction
    @objc func refreshTable() {
        getAreaList()
    }

    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        let mapsStoryboard = UIStoryboard(name: "Maps", bundle: nil)

        guard let mapViewController = mapsStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {return}
        mapViewController.monitoringServices = MonitoringServices(monitoring: Monitoring(area: Area()))
        mapViewController.mapMode = .editingArea
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Editing area"
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    // MARK: - Private functions
    /// get all area in database of user
    private func getAreaList() {
        AreaServices.shared.getAreaList() { [weak self] fetchArea in
            switch fetchArea {
            case .success(let listArea):
                self?.listArea = listArea
                self?.areaListTableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.initializeBackgroundTableView()

            case .failure(let error):
                self?.presentAlertError(alertTitle: "🤷‍♂️", alertMessage: error.localizedDescription)
                self?.refreshControl.endRefreshing()
            }
        }
    }

    /// set background if user's list is empty
    private func initializeBackgroundTableView() {
        var backgroundImage = UIImage(named: "Military_Outline-Black")
        if listArea.count == 0 {
            if self.traitCollection.userInterfaceStyle == .dark {
                backgroundImage = UIImage(named: "Military_Outline-White")
            } else {
                backgroundImage = UIImage(named: "Military_Outline-Black")
            }

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
        return listArea.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)
        let cellIsSelected = areaSelected == listArea[indexPath.row].name

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AreaCellTableViewCell else {
            return UITableViewCell()
        }

        cell.configureCell(infoArea: listArea[indexPath.row], cellIsSelected: cellIsSelected)
        return cell
    }
}

// MARK: - TableView Delegate
extension AreaListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    UserDefaults.standard.set(listArea[indexPath.row].name, forKey: UserDefaultKeys.Keys.areaSelected)
    tableView.deselectRow(at: indexPath, animated: false)
    tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            askDelete(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        transferToMapViewController(area: listArea[indexPath.row])
    }

    // MARK: - private func tableView

    /// Ask confirmation before delete area
    /// - Parameter indexPath: index of area selected
    private func askDelete (indexPath: IndexPath) {
        let alertVC = UIAlertController(
            title: "Delete area",
            message: "Are you sure you want delete this area",
            preferredStyle: .actionSheet
        )

        let deletingAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteArea(indexPath)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        cancel.setValue(UIColor.label, forKey: "titleTextColor")
        alertVC.addAction(cancel)
        alertVC.addAction(deletingAction)
        present(alertVC, animated: true, completion: nil)
    }

    /// delete area selected
    /// - Parameters:
    ///   - indexPath: cell area detect
    ///   - user: user signIn
    private func deleteArea(_ indexPath: IndexPath) {
        guard let areaName = listArea[indexPath.row].name else {
            return
        }

        AreaServices.shared.removeArea(name: areaName) { [weak self] result in
            switch result {
            case .success(_):
                self?.getAreaList()
                self?.presentNativeAlertSuccess(alertMessage: "Area Deleting")
                UserDefaults.standard.set("", forKey: UserDefaultKeys.Keys.areaSelected)
            case.failure(let error):
                self?.getAreaList()
                self?.presentAlertError(
                    alertTitle: "Error",
                    alertMessage: error.localizedDescription,
                    buttonTitle: "Dismiss",
                    alertStyle: .cancel
                )
            }
        }
    }

    /// transfert to MapViewController
    /// - Parameter area: area selected
    private func transferToMapViewController(area: Area) {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        let monitoringService = MonitoringServices(monitoring: Monitoring(area: area))
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {return}

        mapViewController.monitoringServices = monitoringService
        mapViewController.mapMode = .editingArea
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Editing area"
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
