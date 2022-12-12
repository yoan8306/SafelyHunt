//
//  MainStarterViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//
import GoogleMobileAds
import UIKit
import FirebaseAuth
import MapKit

class MainStarterViewController: UIViewController {
    // MARK: - Properties
    var area: Area?
    var person = Person()
    

    // MARK: - IBOutlet
    @IBOutlet weak var startMonitoringButton: UIButton!
    @IBOutlet weak var huntingTableView: UITableView!

    @IBOutlet weak var bannerView: GADBannerView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        initPerson()
        initAdMob()
    }

    /// set interface when view appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if person.personMode == .hunter {
            getSelectedArea()
        }
        huntingTableView.reloadData()
        insertShimmeringInButton()
    }

    /// Show message if no area selected
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentTutorielIfNeeded()
        presentAlertMessage()
        initPerson()
        setButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        startMonitoringButton.titleLabel?.stopShimmering()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setButton()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        setButton()
    }

    // MARK: - IBAction
    @IBAction func startMonitoringButton(_ sender: UIButton) {
        if person.personMode == .hunter {
            if area != nil {
                presentMapView()
            } else {
                presentAlertError(alertMessage: "Your area is not loaded go in your area list and try again".localized(tableName: "LocalizableMainStarter"))
            }
        } else {
            presentMapView()
        }
    }

    // MARK: - Private functions
    private func initPerson() {
        UserServices.shared.getProfileUser { [weak self] profileUser in
            switch profileUser {
            case .failure(_):
                break
            case .success(let person):
                self?.person = person
                self?.person.personMode = PersonMode(rawValue: UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.personMode) ?? "unknown")
            }
        }
    }

    /// Download area selected
    private func getSelectedArea() {
        let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)
        AreaServices.shared.getArea(nameArea: areaSelected) { [weak self] success in
            switch success {
            case .success(let area):
                self?.area = area
            case .failure(_):
                guard UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) != "" else {return}
                self?.presentAlertError(alertMessage: "Check your connection network".localized(tableName: "LocalizableMainStarter"))
            }
        }
    }

    /// If no area selected present alert message
    private func presentAlertMessage() {
        if UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) == "" && person.personMode == .hunter {
            presentAlertError(alertTitle: "👋", alertMessage: "Please select your area in your list.".localized(tableName: "LocalizableMainStarter"))
        } else if person.personMode == .walker {
            presentAlertSuccess(alertTitle: "👋", alertMessage: "Hello, You can start monitoring. You will receive an alert and you will see the hunting area if you are nearby.".localized(tableName: "LocalizableMainStarter"))
        }
    }

    /// Transfer to MapViewController with monitoring object
    private func presentMapView() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {return}

        let monitoringService: MonitoringServicesProtocol = MonitoringServices(monitoring: Monitoring(area: area ?? Area(), person: person))

        mapViewController.monitoringServices = monitoringService
        mapViewController.mapMode = .monitoring
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.myNavigationItem.title = "Ready for monitoring".localized(tableName: "LocalizableMainStarter")
        tabBarController?.tabBar.isHidden = true
        self.present(mapViewController, animated: true)
    }

    /// Set button design
    private func setButton() {
        startMonitoringButton.layer.cornerRadius = startMonitoringButton.frame.height/2
        enableButtonIfPossible()
        guard startMonitoringButton.isEnabled else {
            let brownColor =  #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
            startMonitoringButton.backgroundColor = #colorLiteral(red: 0.2238582075, green: 0.3176955879, blue: 0.2683802545, alpha: 1)
            startMonitoringButton.setTitleColor(brownColor, for: .disabled)
            startMonitoringButton.layer.opacity = 0.75
            return
        }
        startMonitoringButton.backgroundColor = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        startMonitoringButton.setTitleColor(.black, for: .normal)
        startMonitoringButton.layer.opacity = 1
    }

    private func enableButtonIfPossible() {
        if person.personMode == .hunter {
            startMonitoringButton.isEnabled = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) != ""
        } else {
            startMonitoringButton.isEnabled = true
        }
    }

    private func setButtonLightOrDarkMode() {
        if self.traitCollection.userInterfaceStyle == .dark {
            startMonitoringButton.backgroundColor = .white
            startMonitoringButton.setTitleColor(.black, for: .normal)
        } else {
            startMonitoringButton.backgroundColor = .black
            startMonitoringButton.setTitleColor(.white, for: .normal)
        }
    }

    /// if area selected start shimmering
    private func insertShimmeringInButton() {
        if UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected) != "" || person.personMode == .walker {
            startMonitoringButton.startShimmering()
        } else {
            startMonitoringButton.stopShimmering()
        }
    }

    /// Present carousel tutorial
    private func presentTutorielIfNeeded() {
        if person.personMode == .hunter {
            if !UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.tutorialHasBeenSeen) {
                presentCarousel()
            }
        }
    }

    private func presentCarousel() {
        let carouselStoryboard = UIStoryboard(name: "Carousel", bundle: nil)

        guard let carouselVC = carouselStoryboard.instantiateViewController(withIdentifier: "CarouselStoryboard") as? CarouselViewController else {
            return
        }
        present(carouselVC, animated: true)
    }
    
    /// init AdMob banner
    private func initAdMob() {
        let bannerIDTest = "ca-app-pub-3940256099942544/2934735716"
        let bannerIDProd = "ca-app-pub-3063172456794459/9677510087"
        bannerView.adUnitID = bannerIDTest
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
}

// MARK: - TableView DataSource
extension MainStarterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if person.personMode == .hunter {
                return MainData.mainStarter.count
            } else {
                return 0
            }

        case 1:
            return MainData.informations.count
        default: return 0
        }
    }

    /// create cell of table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellStarter", for: indexPath)

        if person.personMode == .hunter && indexPath.section == 0 {
            let title = MainData.mainStarter[indexPath.row]
            configureCellHunter(cell, title, indexPath)
        } else {
            let title = MainData.informations[indexPath.row]
            configureCellInformation(cell, title)
        }

        return cell
    }

    /// configure each cell of table view
    private func configureCellHunter(_ cell: UITableViewCell, _ title: String, _ indexPath: IndexPath) {
        let areaSelected = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.areaSelected)
        let radiusAlert = UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert)
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
        content.textProperties.color = .black
        content.secondaryTextProperties.color = .black
        cell.contentConfiguration = content
    }

    private func configureCellInformation(_ cell: UITableViewCell, _ title: String) {
        var content = cell.defaultContentConfiguration()
        content.text = title
        content.textProperties.color = .black
        cell.contentConfiguration = content
    }

}

// MARK: - TableView Delegate
extension MainStarterViewController: UITableViewDelegate {
    /// action for cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                transferToAreaListViewController()
            case 1:
                transferToMapForSetRadiusAlert()
            default: break
            }

        case 1:
            switch indexPath.row {
            case 0:
                tableView.deselectRow(at: indexPath, animated: true)
                transferToLevelProfile()
//                presentAlertError(alertTitle: "", alertMessage: "In the next update you can win badge. \nPlease Wait 😉")
            case 1:
                tableView.deselectRow(at: indexPath, animated: true)
                if let url = URL(string: "https://www.chasseurdefrance.com/pratiquer/dates-de-chasse/") {
                    UIApplication.shared.open(url)
                }

            default: break
            }
        default: break
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    /// transfert to AreaListViewController
    private func transferToAreaListViewController() {
        let areaListStoryboard = UIStoryboard(name: "AreasList", bundle: nil)

        guard let areaListViewController = areaListStoryboard.instantiateViewController(withIdentifier: "AreasList") as? AreaListViewController else {return}
        areaListViewController.person = person
        areaListViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(areaListViewController, animated: true)
    }

    /// Transfert for set radius alert in MapViewController
    private func transferToMapForSetRadiusAlert() {
        let mapViewStoryboard = UIStoryboard(name: "Maps", bundle: nil)
        guard let mapViewController = mapViewStoryboard.instantiateViewController(withIdentifier: "MapView") as? MapViewController else {return}
        let monitoringService = MonitoringServices(monitoring: Monitoring(area: Area(), person: person))
        mapViewController.monitoringServices = monitoringService
        mapViewController.mapMode = .editingRadius
        mapViewController.myNavigationItem.title = "Set radius alert".localized(tableName: "LocalizableMainStarter")
        mapViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    private func transferToLevelProfile() {
        let levelProfileStoryboard = UIStoryboard(name: "LevelProfile", bundle: nil)

        guard let levelProfileViewController = levelProfileStoryboard.instantiateViewController(withIdentifier: "LevelProfile") as? LevelProfileViewController else {return}

        levelProfileViewController.person = person
        navigationController?.pushViewController(levelProfileViewController, animated: true)
    }

}
