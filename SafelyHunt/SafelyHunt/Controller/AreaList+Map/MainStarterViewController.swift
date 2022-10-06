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
    // MARK: - Properties
    var area: Area?
    var hunter = Hunter()

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
        getSelectedArea()
        tableView.reloadData()
    }

    // MARK: - IBAction
    @IBAction func startMonitoringButton(_ sender: UIButton) {
        if UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) != "" {
            tabBarController?.tabBar.isHidden = true
            presentMapView()
        } else {
            presentAlertError(alertMessage: "Select an area for start")
        }
    }

    // MARK: - Private functions
    /// Download area selected
    private func getSelectedArea() {
        let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)

        AreaServices.shared.getArea(nameArea: areaSelected) { [weak self] success in
            switch success {
            case .success(let area):
                self?.area = area
            case .failure(_):
                self?.presentAlertError(alertTitle: "👋", alertMessage: "Please select your area in your list.")
                return
            }
        }
    }

    /// Transferr to MapViewController with monitoring object
    private func presentMapView() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController, let area = area else {
            return
        }

        let monitoringService: MonitoringServicesProtocol = MonitoringServices(monitoring: Monitoring(area: area, hunter: hunter))

        mapViewController.monitoringServices = monitoringService
        mapViewController.mapMode = .monitoring
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Ready for monitoring"
        self.present(mapViewController, animated: true)
    }
}

// MARK: - TableView DataSource
extension MainStarterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainData.mainStarter.count
    }

    /// create cell of table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellStarter", for: indexPath)
        let title = MainData.mainStarter[indexPath.row]

        configureCell(cell, title, indexPath)
        return cell
    }

    /// configure each cell of table view
    private func configureCell(_ cell: UITableViewCell, _ title: String, _ indexPath: IndexPath) {
        let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)
        let radiusAlert = UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert)
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            switch indexPath.row {
            case 0:
                content.secondaryText = areaSelected
            case 1:
                content.secondaryText = "\(radiusAlert) m"
            default:
                break
            }
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = areaSelected
            case 1:
                cell.detailTextLabel?.text = "\(radiusAlert) m"
            default:
                break
            }
        }
    }
}

// MARK: - TableView Delegate
extension MainStarterViewController: UITableViewDelegate {
    /// action for cell selected
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

    /// transfert to AreaListViewController
    private func transferToAreaListViewController() {
        let areaListStoryboard = UIStoryboard(name: "AreasList", bundle: nil)

        guard let areaListViewController = areaListStoryboard.instantiateViewController(withIdentifier: "AreasList") as? AreaListViewController else {
            return
        }

        areaListViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(areaListViewController, animated: true)
    }

    /// Transfert for set radius alert in MapViewController
    private func transferToMapForSetRadiusAlert() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {
            return
        }
        let monitoringService = MonitoringServices(monitoring: Monitoring(area: Area()))
        mapViewController.monitoringServices = monitoringService
        mapViewController.mapMode = .editingRadius
        mapViewController.myNavigationItem.title = "Set radius alert"
        mapViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}
