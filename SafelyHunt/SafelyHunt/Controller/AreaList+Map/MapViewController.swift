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
    var polygonCurrent = MKPolygon()
    let notification = LocalNotification()
    lazy var pencil: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(pencilButtonAction))
    }()

    // MARK: - IBOutlet

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sliderUiView: UIView!
    @IBOutlet weak var popUpAreaNameUiView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var travelInfoUiView: UIView!

    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusAlertLabelStatus: UILabel!

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var monitoringButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameAreaTextField: UITextField!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switchButtonRadiusAlert: UISwitch!
    @IBOutlet weak var pickerMapMode: UIPickerView!
    @IBOutlet weak var distanceTraveledLabel: UILabel!

    @IBOutlet weak var currentAltitude: UILabel!
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        askAuthorizations()
        initializeMapView()
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            drawAreaSelected()
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
        nameAreaTextField.becomeFirstResponder()
        editingArea = false
        popUpAreaNameUiView.isHidden = false
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if editingArea {
            turnOffEditingMode()
        }
//        monitoringServices.startMonitoring = false
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
            navigationController?.navigationBar.backgroundColor = .red
            mapView.removeOverlays(mapView.overlays)
            mapView.isUserInteractionEnabled = false
            editingArea  = true
            myNavigationItem.title = "Draw area with finger"
        } else {
            turnOffEditingMode()
        }
    }

    /// get name new area
    @IBAction func validateButtonAction() {
       createArea()

        turnOffEditingMode()
    }

    /// cancel new area
    @IBAction func cancelButtonAction() {
        turnOffEditingMode()
        mapView.removeOverlays(mapView.overlays)
        nameAreaTextField.text = ""
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
            if !monitoringServices.startMonitoring {
                timerForStart = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startMonitoring), userInfo: nil, repeats: true)
            } else {
                monitoringOff()
            }
    }

    @IBAction func switchButtonActionRadiusAlert() {
        UserDefaults.standard.set(switchButtonRadiusAlert.isOn, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        radiusAlertLabelStatus.text = switchButtonRadiusAlert.isOn ? "Radius alert is enable" : "Radius alert is disable"
    }

    @objc func updateMonitoring() {
        checkIfUserIsInsideArea()
        checkIfOthersUsersAreInsideAreaAlert()
        monitoringServices.insertMyPosition()
    }

    @objc func startMonitoring() {
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

    private func askAuthorizations() {
        mapView.delegate = self
        locationManager.delegate = self
        if #available(iOS 14.0, *) {
            handleAuthorizationStatus(status: locationManager.authorizationStatus)
        } else {
            handleAuthorizationStatus(status: CLLocationManager.authorizationStatus())
        }

        if mapMode != .editingArea {
            mapView.setUserTrackingMode(.follow, animated: false)
        }
    }

    private func initializeMapView() {
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.frame.origin = CGPoint(x: travelInfoUiView.frame.origin.x + 5, y: travelInfoUiView.frame.origin.y + travelInfoUiView.frame.height + 20)
        compassButton.compassVisibility = .adaptive
        view.addSubview(compassButton)
        activityIndicator.layer.cornerRadius = activityIndicator.layer.frame.height/2
        activityIndicator.isHidden = true
        locationButton.layer.cornerRadius = locationButton.layer.frame.height/2
        settingsButton.layer.cornerRadius = settingsButton.frame.height / 2
        notification.notificationInitialize()
        setPopUpMessageNameArea()
        editingArea = false
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = false
        mapView.setUserTrackingMode(.follow, animated: false)
        initialzeMapModView()
    }

    private func initialzeMapModView() {
        switch mapMode {
        case .editingArea:
            initialzeEditingAreaView()

        case .editingRadius:
            initializeEditingRadiusView()

        case .monitoring:
         initializeMonitoringView()
        }
    }

    private func initialzeEditingAreaView() {
        navigationItem.rightBarButtonItem = pencil
        travelInfoUiView.isHidden = true
    }

    private func initializeEditingRadiusView() {
        slider.value = Float(UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert))
        radiusLabel.text = "\(Int(slider.value)) m"
        insertRadius()
        sliderUiView.backgroundColor = nil
        sliderUiView.isHidden = false
        travelInfoUiView.isHidden = true
    }

    private func initializeMonitoringView() {
        monitoringButton.isHidden = false
        settingsView.isHidden = true
        switchButtonRadiusAlert.isOn  = UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        switchButtonActionRadiusAlert()
        monitoringButton.layer.cornerRadius = monitoringButton.layer.frame.height/2
        travelInfoUiView.isHidden = false
    }

    private func createArea() {
        guard let name = nameAreaTextField.text, !name.isEmpty else {
            return
        }
        let coordinateArea = monitoringServices.monitoring.area.coordinatesPoints
        let polygonCreate = MKPolygon(coordinates: coordinateArea, count: coordinateArea.count)
        let positionPolygon = CLLocation(latitude: polygonCreate.coordinate.latitude, longitude: polygonCreate.coordinate.longitude)
        var city: String?

        CLGeocoder().reverseGeocodeLocation(positionPolygon) { places, _ in
            guard let firstPlace = places?.first else {
                return
            }
            city = firstPlace.locality
            let area = Area()
            area.name = name
            area.date = String(Date().dateToTimeStamp())
            area.coordinatesPoints = coordinateArea
            area.city = city

            AreaServices.shared.insertArea(area: area, date: Date())
        }
    }

    // MARK: - Map mode Editing
// Private func
    private func setPopUpMessageNameArea() {
        popUpAreaNameUiView.layer.cornerRadius = 8
        popUpAreaNameUiView.isHidden = true
    }

    private func turnOffEditingMode() {
        popUpAreaNameUiView.isHidden = true
        nameAreaTextField.resignFirstResponder()
        monitoringServices.monitoring.area.coordinatesPoints = []
        mapView.isUserInteractionEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
        editingArea = false
    }

    private func drawAreaSelected() {
        let areaSelected = monitoringServices.monitoring.area
        activityIndicator.isHidden = false
        AreaServices.shared.getArea(nameArea: areaSelected.name) { [weak self] result in
            switch result {
            case .success(let area):
                self?.insertAreaInMapView(area: area)
                if self?.mapMode == .monitoring {
                    self?.monitoringAction()
                }
                self?.activityIndicator.isHidden = true
            case .failure(_):
                self?.activityIndicator.isHidden = true
                return
            }
        }
    }

    private func insertAreaInMapView(area: Area) {
        var overlay: [String: MKOverlay] = [:]
        overlay.removeAll()
        overlay["polyLine"] = MKPolyline(coordinates: area.coordinatesPoints, count: area.coordinatesPoints.count)
        overlay["polygon"] = MKPolygon(coordinates: area.coordinatesPoints, count: area.coordinatesPoints.count)
        polygonCurrent = MKPolygon(coordinates: area.coordinatesPoints, count: area.coordinatesPoints.count)

        guard let polyLine = overlay["polyLine"], let polygon = overlay["polygon"] else {
            return
        }
        mapView.addOverlay(polyLine)
        mapView.addOverlay(polygon)

        // define center map zoom
        if let center = overlay["polygon"]?.coordinate, mapMode == .editingArea {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }

    }

    private func insertRadius() {
        let radius = CLLocationDistance(UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.radiusAlert))
        guard let userPosition = locationManager.location?.coordinate else {
            return
        }
        removeRadiusOverlay()

        mapView.addOverlay(monitoringServices.monitoring.area.createCircle(userPosition: userPosition, radius: radius))
    }

    private func removeRadiusOverlay() {
        var overlay: MKOverlay?

        for element in  mapView.overlays where element is MKCircle {
            overlay = element
        }

        if let overlay = overlay {
            mapView.removeOverlay(overlay)
        }
    }
}

// MARK: - MapMode Monitoring
extension MapViewController {
    // Private funcions
    private func monitoringOn() {
        let imageStop = UIImage(systemName: "stop.circle")
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(updateMonitoring), userInfo: nil, repeats: true)
        monitoringServices.startMonitoring = !monitoringServices.startMonitoring
        monitoringButton.setImage(imageStop, for: .normal)
        monitoringButton.tintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }

    private func animateButtonMonitoring() {
        UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.monitoringButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.monitoringButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }

    private func monitoringOff() {
        let imageStart = UIImage(systemName: "play.fill")
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        monitoringServices.startMonitoring = false
        removeRadiusOverlay()
        mapView.removeAnnotations(mapView.annotations)
        monitoringButton.setImage(imageStart, for: .normal)
        monitoringButton.layer.removeAllAnimations()
        self.dismiss(animated: true)
    }

    private func checkIfUserIsInsideArea() {
        guard let positionUser = locationManager.location?.coordinate else {
            return
        }
        if !monitoringServices.checkUserIsAlwayInArea(area: polygonCurrent, positionUser: positionUser) {
            let banner = NotificationBanner(title: "Attention", subtitle: "You are exit of your area", leftView: nil, rightView: nil, style: .danger, colors: nil)
            notification.sendNotification()
            banner.show()
        }
    }

    private func checkIfOthersUsersAreInsideAreaAlert() {
        monitoringServices.checkUserIsInRadiusAlert { [weak self] result in
            switch result {
            case .success(let usersIsInRadiusAlert):
                guard usersIsInRadiusAlert.isEmpty == false else {
                    return
                }
                let allowsNotification = UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
                self?.mapView.removeAnnotations((self?.mapView.annotations)!)
                    self?.insertHunterInMap(usersIsInRadiusAlert)
                    self?.insertRadius()

                    if allowsNotification {
                        let bannerRadius = FloatingNotificationBanner(title: "Attention", subtitle: "Others users are near you", style: .info)
                        bannerRadius.show(cornerRadius: 8, shadowBlurRadius: 16)
                        self?.notification.sendNotification()
                    }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func insertHunterInMap(_ arrayHunters: [Hunter]) {
        if arrayHunters.count > 0 {
            for hunter in arrayHunters {
                guard let latitude = hunter.latitude, let longitude = hunter.longitude else {
                    return
                }
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let showHunter = PlaceHunters(title: hunter.displayName ?? "no name", coordinate: coordinate, subtitle: "Last view \(Date().getTime(dateInt: hunter.date ?? 0))")
                mapView.addAnnotation(showHunter)
                mapView.register(AnnotationHuntersView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            }

        } else {
            removeRadiusOverlay()
            mapView.removeAnnotations(mapView.annotations)
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getInfoDistanceAndAltitude(locations)
        getDistanceTraveled(locations)
        getPostionUser(locations)
    }

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

   private func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            if locationManager.desiredAccuracy != kCLLocationAccuracyBest {
                presentAlertError(alertMessage: "I need exact position for best monitoring, you can change in your setting")
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingHeading()
            mapView.showsUserLocation = true
        case .denied:
            presentAlertError(alertMessage: "Go to settings for accept localization")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    private func getInfoDistanceAndAltitude(_ locations: [CLLocation]) {
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

    private func getPostionUser(_ locations: [CLLocation]) {
        guard let hunter = monitoringServices.monitoring.hunter else {
            return
        }
        hunter.latitude = locations.first?.coordinate.latitude
        hunter.longitude = locations.first?.coordinate.longitude
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

// MARK: - Textfield delegate
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateButtonAction()
        return true
    }
}

// MARK: - PickerView datasource
extension MapViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
}
// MARK: - PickerView delegate
extension MapViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        default: mapView.mapType = .standard
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center

        switch row {
        case 0:
            label.text = "standard"
        case 1:
            label.text = "satellite"
        default: break
        }
        return label
    }
}
