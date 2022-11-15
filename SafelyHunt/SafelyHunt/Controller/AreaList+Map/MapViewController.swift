//
//  MapViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import UIKit
import MapKit
import FirebaseAuth
import NotificationBannerSwift

class MapViewController: UIViewController {
    // MARK: - Properties
    var monitoringServices: MonitoringServicesProtocol!
    var locationManager = CLLocationManager()
    var mapMode: MapMode = .monitoring
    var editingArea = false
    var areaSelected = Area()
    var timer: Timer?
    var timerForStart: Timer?
    var second = 3
    let notification = LocalNotification()
    lazy var pencil: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(pencilButtonAction)
        )
    }()
    let colorTintButton = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)

    // MARK: - IBOutlet
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sliderUiView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var travelInfoUiView: UIView!

    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusAlertLabelStatus: UILabel!
    @IBOutlet weak var distanceTraveledLabel: UILabel!
    @IBOutlet weak var currentAltitude: UILabel!

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var monitoringButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switchButtonRadiusAlert: UISwitch!
    @IBOutlet weak var pickerMapMode: UIPickerView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askAuthorizationsForLocalizationUser()
        drawAreaSelected()
        if mapMode == .monitoring {
            monitoringAction()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        if mapMode == .monitoring {
            monitoringServices.insertDistanceTraveled()
        }
    }

    /// When user touch map, create polyline or not
    /// - Parameters:
    ///   - touches: user touch screen
    ///   - event: event touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            monitoringServices.monitoring.area.coordinatesPoints.append(coordinate)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            monitoringServices.monitoring.area.coordinatesPoints.append(coordinate)
            mapView.addOverlay(monitoringServices.monitoring.area.createPolyLine())
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        mapView.addOverlay(monitoringServices.monitoring.area.createPolygon())
        editingArea = false
        presentPopUpNewNameArea()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if editingArea {
            turnOffEditingMode()
        }
    }

    // MARK: - IBAction
    @IBAction func gearButtonAction() {
        settingsView.isHidden = !settingsView.isHidden
    }

    /// localize user
    @IBAction func locationButtonAction() {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        locationManager.allowsBackgroundLocationUpdates = true
    }

    // Map mode Editing Area
    /// drawArea
    @objc func pencilButtonAction() {
        if !editingArea {
            mapView.removeOverlays(mapView.overlays)
            mapView.isUserInteractionEnabled = false
            editingArea  = true
            setTitleSizeNavigationBar()
        } else {
            turnOffEditingMode()
        }
    }

    private func setTitleSizeNavigationBar() {
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        title = "Draw your area".localized(tableName: "LocalizableMapView")
    }

    // Map mode Editing radius
    /// define radius
    @IBAction func sliderAction() {
        radiusLabel.text = "\(Int(slider.value)) m"
        UserDefaults.standard.set(Int(slider.value), forKey: UserDefaultKeys.Keys.radiusAlert)
        insertRadius()
    }

    @IBAction func subtractButtonAction() {
        slider.value -= 1
        sliderAction()
    }

    @IBAction func addButtonAction() {
        slider.value += 1
        sliderAction()
    }

    // Map mode Monitoring
    /// Start / off monitoring
    @IBAction func monitoringAction() {
        if statusAuthorizationLocation() {
            if !monitoringServices.startMonitoring {
                timerForStart = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(timerBeforeStart),
                    userInfo: nil,
                    repeats: true
                )

                monitoringServices.startMonitoring = true
                self.modalPresentationStyle = .fullScreen
            } else {
                monitoringOff()
            }
        }
    }

    /// enable / disable notification on radius alert
    @IBAction func switchButtonActionRadiusAlert() {
        UserDefaults.standard.set(
            switchButtonRadiusAlert.isOn,
            forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert
        )

        radiusAlertLabelStatus.text = switchButtonRadiusAlert.isOn ? "Radius alert is enable".localized(tableName: "LocalizableMapView") : "Radius alert is disable".localized(tableName: "LocalizableMapView")
    }

    /// monitoring user.  action call by tilmer
    @objc func updateMonitoring() {
        guard let person = monitoringServices.monitoring.person else {return}

        switch person.personMode {
        case .hunter:
            checkIfUserIsInsideArea()
            checkIfOthersUsersAreInsideAreaAlert()
        default:
            checkIfOthersUsersAreInsideAreaAlert()
        }
        monitoringServices.insertUserPosition()
    }

    /// count timerfor start before start monitoring
    @objc func timerBeforeStart() {
        if second > 0 {
            monitoringButton.setImage(nil, for: .normal)
            monitoringButton.setTitle(String(second), for: .normal)
            second -= 1
        } else {
            monitoringButton.setTitle("", for: .normal)
            timerForStart?.invalidate()
            second = 3
            monitoringOn()
            animateButtonMonitoring()
        }
    }

    // MARK: - InitializeView
    // Private func
    private func initializeMapView() {
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.frame.origin = CGPoint(
            x: travelInfoUiView.frame.origin.x + 5,
            y: travelInfoUiView.frame.height + 80
        )
        compassButton.compassVisibility = .adaptive
        view.addSubview(compassButton)

        activityIndicator.layer.cornerRadius = activityIndicator.layer.frame.height/2
        activityIndicator.isHidden = true
        locationButton.layer.cornerRadius = locationButton.layer.frame.height/2
        settingsButton.layer.cornerRadius = settingsButton.frame.height / 2
        settingsView.layer.cornerRadius = 8

        editingArea = false
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        notification.notificationInitialize()
        initializePickerView()
        initialzeMapModView()
    }

    /// set mapStyle
    /// - Parameter rowSelected: last mapStyle using by user
    private func initializePickerView(rowSelected: Int = UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.mapTypeSelected)) {
        pickerMapMode.selectRow(rowSelected, inComponent: 0, animated: true)
        pickerView(pickerMapMode, didSelectRow: rowSelected, inComponent: 0)
    }

    /// Initialize View
    private func initialzeMapModView() {
        switch mapMode {
        case .editingArea:
            initialzeEditingAreaView()

        case .editingRadius:
            initializeEditingRadiusView()

        case .monitoring:
            initializeMonitoringView()
        }
        trackingMode()
    }

    /// case editing mode set navigationView
    private func initialzeEditingAreaView() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.rightBarButtonItem = pencil
        travelInfoUiView.isHidden = true
    }

    /// case editing radius mode showand set  slider
    private func initializeEditingRadiusView() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        slider.value = Float(UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert))
        radiusLabel.text = "\(Int(slider.value)) m"
        sliderUiView.backgroundColor = nil
        sliderUiView.isHidden = false
        travelInfoUiView.isHidden = true
        insertRadius()
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.showInfoRadius) {
            presentInfoRadius()
        }
    }

    private func trackingMode() {
        if monitoringServices.monitoring.area.coordinatesPoints.isEmpty {
            mapView.setUserTrackingMode(.follow, animated: false)
        } else if mapMode != .editingArea {
            mapView.setUserTrackingMode(.follow, animated: false)
        }
    }

    /// Describe raidus what is radius alert
    private func presentInfoRadius() {
        let alertViewController = UIAlertController(
            title: "Info",
            message: "Set the alert distance between you and other users. You will be alerted if someone enters your range and it will be displayed on the map.".localized(tableName: "LocalizableMapView"),
            preferredStyle: .alert
        )

        let dismiss = UIAlertAction(title: "Dismiss".localized(tableName: "Localizable"), style: .default)
        let dontShowInfoRadius = UIAlertAction(title: "Do not see this message again".localized(tableName: "LocalizableMapView"), style: .cancel) { _ in
            UserDefaults.standard.set(false, forKey: UserDefaultKeys.Keys.showInfoRadius)
        }
        dontShowInfoRadius.setValue(colorTintButton, forKey: "titleTextColor")
        alertViewController.addAction(dontShowInfoRadius)
        alertViewController.addAction(dismiss)
        present(alertViewController, animated: true, completion: nil)
    }

    /// case monitoring mode show monitioring button and travel information
    private func initializeMonitoringView() {
        monitoringButton.isHidden = false
        settingsView.isHidden = true
        switchButtonRadiusAlert.isOn  = UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        monitoringButton.layer.cornerRadius = monitoringButton.layer.frame.height/2
        travelInfoUiView.isHidden = false
        switchButtonActionRadiusAlert()
    }

    //    check createPolygon function
    private func createArea(nameArea: String) {
        let coordinateArea = monitoringServices.monitoring.area.coordinatesPoints
        let polygonCreate = MKPolygon(coordinates: coordinateArea, count: coordinateArea.count)
        let positionPolygon = CLLocation(
            latitude: polygonCreate.coordinate.latitude,
            longitude: polygonCreate.coordinate.longitude
        )

        var city: String?

        CLGeocoder().reverseGeocodeLocation(positionPolygon) { [weak self] places, _ in
            guard let personId = self?.monitoringServices.monitoring.person?.uId else {return}

            guard let firstPlace = places?.first else {return}
            city = firstPlace.locality

            let area = Area()
            area.name = nameArea
            area.date = String(Date().dateToTimeStamp())
            area.coordinatesPoints = coordinateArea
            area.city = city

            AreaServices.shared.insertArea(area: area, date: Date(), uId: personId)
            self?.presentNativeAlertSuccess(alertMessage: nameArea + " is recorded success".localized(tableName: "LocalizableMapView"))
        }
    }

    // MARK: - Map mode Editing
    // Private func
    private func turnOffEditingMode() {
        monitoringServices.monitoring.area.coordinatesPoints = []
        mapView.isUserInteractionEnabled = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.isTranslucent = true
        myNavigationItem.title = "Editing area".localized(tableName: "LocalizableAreaListViewController")
        editingArea = false
    }

    /// Draw area selected if area exist
    private func drawAreaSelected() {
        if !monitoringServices.monitoring.area.coordinatesPoints.isEmpty {
            activityIndicator.isHidden = false
            insertAreaInMapView(area: monitoringServices.monitoring.area)
            activityIndicator.isHidden = true
        }
    }

    private func getAreaForbidden() {
        guard let person = monitoringServices.monitoring.person else {return}
        mapView.removeOverlays(mapView.overlays)
        AreaServices.shared.getAreaForbidden(uId: person.uId) { [weak self] success in
            switch success {
            case .failure(_):
                return
            case.success(let area):
                self?.monitoringServices.monitoring.area = area
                self?.drawAreaSelected()
            }
        }
    }

    /// transform area to overlay
    /// - Parameter area: the area selected
    private func insertAreaInMapView(area: Area) {
        var overlay: [String: MKOverlay] = [:]
        overlay.removeAll()
        overlay["polyLine"] = MKPolyline(coordinates: area.coordinatesPoints, count: area.coordinatesPoints.count)
        overlay["polygon"] = MKPolygon(coordinates: area.coordinatesPoints, count: area.coordinatesPoints.count)

        guard let polyLine = overlay["polyLine"], let polygon = overlay["polygon"] else {
            return
        }
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)

        // define center map
        if let center = overlay["polygon"]?.coordinate, mapMode == .editingArea {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    /// insert radius in map
    private func insertRadius() {
        let radiusSaved = CLLocationDistance(UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert))
        let personMode = monitoringServices.monitoring.person?.personMode
        let radius = (personMode == .hunter) ? radiusSaved : 1000

        guard let userPosition = locationManager.location?.coordinate else {
            return
        }

        removeRadiusOverlay()
        mapView.addOverlay(monitoringServices.monitoring.area.createCircle(userPosition: userPosition, radius: radius))
    }

    /// remove last radius overlay in map
    private func removeRadiusOverlay() {
        for element in  mapView.overlays where element is MKCircle {
            mapView.removeOverlay(element)
        }
    }

    /// present popUp for set name new area
    private func presentPopUpNewNameArea() {
        let alertViewController = UIAlertController(
            title: "New area name".localized(tableName: "LocalizableMapView"),
            message: "Enter name for your new area".localized(tableName: "LocalizableMapView"),
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel".localized(tableName: "Localizable"), style: .default) { _ in
            self.turnOffEditingMode()
            self.mapView.removeOverlays(self.mapView.overlays)
        }

        let register = UIAlertAction(title: "Register".localized(tableName: "LocalizableMapView"), style: .cancel) { _ in
            if let textfield = alertViewController.textFields?[0], let nameArea = textfield.text, !nameArea.isEmpty {
                self.createArea(nameArea: nameArea)
                self.turnOffEditingMode()
            } else {
                self.presentPopUpNewNameArea()
            }
        }

        alertViewController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Name area...".localized(tableName: "LocalizableMapView")
        })
        register.setValue(colorTintButton, forKey: "titleTextColor")
        alertViewController.addAction(cancel)
        alertViewController.addAction(register)

        present(alertViewController, animated: true, completion: nil)
    }
}

// MARK: - MapMode Monitoring
private extension MapViewController {
    // Private funcions

    /// Check if authorization Location is enable
    /// - Returns: return true if location is enabled
    func statusAuthorizationLocation() -> Bool {
        if #available(iOS 14.0, *) {
            if locationManager.accuracyAuthorization != .fullAccuracy {
                UIApplicationOpenSetting()
                return false
            }
        } else {
            if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                UIApplicationOpenSetting()
                return false
            }
        }
        return true
    }

    /// Start monitoring
    func monitoringOn() {
        timer = Timer.scheduledTimer(
            timeInterval: 15,
            target: self,
            selector: #selector(updateMonitoring),
            userInfo: nil,
            repeats: true
        )
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        imageStopMonitoringButton()
        updateMonitoring()
    }

    /// set image button monitoring
    func imageStopMonitoringButton() {
        let imageStop = UIImage(systemName: "stop.circle")
        monitoringButton.setImage(imageStop, for: .normal)
        monitoringButton.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }

    func animateButtonMonitoring() {
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.monitoringButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.monitoringButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }

    /// Remove all data in mapView radius, hunters and stop all timers
    func monitoringOff() {
        let imageStart = UIImage(systemName: "play.fill")
        monitoringButton.setImage(imageStart, for: .normal)
        timer?.invalidate()
        timerForStart?.invalidate()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        monitoringServices.startMonitoring = false
        removeRadiusOverlay()
        mapView.removeAnnotations(mapView.annotations) // remove hunters
        monitoringButton.layer.removeAllAnimations()
        dismiss(animated: true)
    }

    /// check if user is always inside area
    func checkIfUserIsInsideArea() {
        let person = monitoringServices.monitoring.person
        guard let positionUser = locationManager.location?.coordinate, let person else {
            return
        }

        if !monitoringServices.checkUserIsAlwayInArea(positionUser: positionUser) && person.personMode == .hunter {
            let banner = NotificationBanner(
                title: "Attention",
                subtitle: "You are exit of your area!".localized(tableName: "LocalizableMapView"),
                leftView: nil,
                rightView: nil,
                style: .danger,
                colors: nil
            )
            notification.sendNotification()
            banner.show()
        }
    }

    /// check if hunters are inside radius alert
    func checkIfOthersUsersAreInsideAreaAlert() {
        mapView.removeAnnotations((mapView.annotations))
        monitoringServices.checkUserIsInRadiusAlert { [weak self] result in
            switch result {
            case .success(let usersIsInRadiusAlert):
                guard usersIsInRadiusAlert.isEmpty == false else {
                    switch self?.monitoringServices.monitoring.person?.personMode {
                    case .hunter:
                        self?.removeRadiusOverlay()
                    default:
                        self?.mapView.removeOverlays((self?.mapView.overlays)!)

                    }
                    return
                }
                self?.insertPersonsInMap(usersIsInRadiusAlert)
                self?.insertRadius()
                if self?.monitoringServices.monitoring.person?.personMode == .walker {
                    self?.getAreaForbidden()
                }
                self?.sendNotificationHuntersInRadius()

            case .failure(_):
                return
            }
        }
    }

    /// share area of hunt with an other
    /// - Parameter person: person identifier
    private func sharedAreaForbbiden(person: Person) {
        let area = monitoringServices.monitoring.area
        AreaServices.shared.transfertAreaIntoUserInForbidden(uId: person.uId, area: area)
    }

    /// insert hunters in map
    /// - Parameter arrayHunters: list hunters present in radius alert
    func insertPersonsInMap(_ persons: [Person]) {
        if persons.count > 0 {
            for person in persons {
                guard let latitude = person.latitude, let longitude = person.longitude, let personMode = person.personMode else {
                    continue
                }
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let personAnnotation = AnnotationPerson(
                    title: (person.displayName ?? "no name")
                    + "(\(personMode.rawValue.localized(tableName: "Localizable")))",
                    coordinate: coordinate,
                    subtitle: "Last view ".localized(tableName: "LocalizableMapView") +  Date(timeIntervalSince1970: TimeInterval(person.date ?? 0)).getTime()
                )

                if person.personMode != .hunter {
                    sharedAreaForbbiden(person: person)
                }

                mapView.addAnnotation(personAnnotation)
                mapView.register(AnnotationPersonsView.self,
                                 forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
                )
            }

        } else {
            removeRadiusOverlay()
            mapView.removeAnnotations(mapView.annotations)
        }
    }

    /// send notification of hunters in radius alert
    func sendNotificationHuntersInRadius() {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert) {
            let bannerRadius = FloatingNotificationBanner(
                title: "Attention",
                subtitle: "Others users are near you".localized(tableName: "LocalizableMapView"),
                style: .info
            )

            bannerRadius.show(cornerRadius: 8, shadowBlurRadius: 16)
            notification.sendNotification()
        }
    }
}

// MARK: - MapView delegate, CLLocationmanager delegate
extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {

    // Location ManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            handleAuthorizationStatus(status: locationManager.authorizationStatus)
        } else {
            handleAuthorizationStatus(status: CLLocationManager.authorizationStatus())
        }
    }

    /// update distance and altitude during monioring
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        transferDistanceAndAltitudeToLabel(locations)
        getDistanceTraveled(locations)
        updatePostion(locations)
    }

    /// design polygon polyline and circle
    /// - Parameters:
    ///   - mapView: mapview
    ///   - overlay: overlay designed
    /// - Returns: overlayRenderer
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            return createPolyLineRenderer(overlay)

        case is MKPolygon:
            return createPolygonView(overlay)

        case is MKCircle:
            return createCircleView(overlay)

        default:
            return MKPolylineRenderer(overlay: overlay)
        }
    }

    private func askAuthorizationsForLocalizationUser() {
        mapView.delegate = self
        locationManager.delegate = self
        if #available(iOS 14.0, *) {
            handleAuthorizationStatus(status: locationManager.authorizationStatus)
        } else {
            handleAuthorizationStatus(status: CLLocationManager.authorizationStatus())
        }
    }

    /// check if location authorization status change
    /// - Parameter status: authorization type selected
    private func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if #available(iOS 14.0, *) {
                if locationManager.accuracyAuthorization != .fullAccuracy {
                    UIApplicationOpenSetting()
                }
            } else {
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
            }
            mapView.showsUserLocation = true
        case .denied, .restricted:
            UIApplicationOpenSetting()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    /// open setting app if needed
    private func UIApplicationOpenSetting() {

        let alertVC = UIAlertController(
            title: "Error".localized(tableName: "Localizable"),
            message: "We need exact position for best monitoring, you can change in your setting".localized(tableName: "LocalizableMapView"),
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel".localized(tableName: "Localizable"), style: .default) { _ in
            if self.mapMode == .monitoring {
                self.dismiss(animated: true)
            }
        }
        let openSetting = UIAlertAction(title: "Open setting", style: .cancel) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        openSetting.setValue(colorTintButton, forKey: "titleTextColor")
        alertVC.addAction(cancel)
        alertVC.addAction(openSetting)
        present(alertVC, animated: true, completion: nil)
    }

    private func transferDistanceAndAltitudeToLabel(_ locations: [CLLocation]) {
        let distanceTraveled = monitoringServices.monitoring.measureDistanceTravelled(locations: locations)
        distanceTraveledLabel.text = String(format: "%.2f", distanceTraveled) + " km"
        currentAltitude.text = String(format: "%.0f", locations.first!.altitude) + " m"
    }

    /// Draw polyLine travel
    /// - Parameter locations: user's travelled
    private func getDistanceTraveled(_ locations: [CLLocation]) {
        monitoringServices.monitoring.getCurrentTravel(locations: locations)
        monitoringServices.monitoring.area.coordinateTravel = monitoringServices.monitoring.currentTravel
        mapView.addOverlay(monitoringServices.monitoring.area.createPolyLineTravel())
    }

    private func updatePostion(_ locations: [CLLocation]) {
        guard let person = monitoringServices.monitoring.person else {
            return
        }
        person.latitude = locations.first?.coordinate.latitude
        person.longitude = locations.first?.coordinate.longitude
    }

    private func createPolyLineRenderer(_ overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        polyLineRenderer.strokeColor = UIColor.darkGray
        polyLineRenderer.lineWidth = 1
        return polyLineRenderer
    }

    private func createPolygonView(_ overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonView = MKPolygonRenderer(overlay: overlay)
        polygonView.fillColor = .red
        polygonView.alpha = 0.3
        return polygonView
    }

    private func createCircleView(_ overlay: MKOverlay) -> MKOverlayRenderer {
        let circleView = MKCircleRenderer(overlay: overlay)
        circleView.fillColor = .red
        circleView.strokeColor = UIColor.blue
        circleView.lineWidth = 1
        circleView.alpha = 0.3
        return circleView
    }
}

// MARK: - PickerView datasource
extension MapViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
}
// MARK: - PickerView delegate
extension MapViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .mutedStandard
        case 2:
            mapView.mapType = .hybridFlyover
        default: mapView.mapType = .standard
        }
        UserDefaults.standard.set(row, forKey: UserDefaultKeys.Keys.mapTypeSelected)
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = MainData.pickerMapType[row]
        label.textColor = .black
        return label
    }
}
