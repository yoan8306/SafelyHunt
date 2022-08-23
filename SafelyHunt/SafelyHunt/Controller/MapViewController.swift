//
//  MapViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import UIKit
import MapKit
import FirebaseAuth
import AudioToolbox
import NotificationBannerSwift

class MapViewController: UIViewController {
    // MARK: - Properties
    var hunter = Hunter()
    var locationManager = CLLocationManager()
    var mapMode: MapMode = .monitoring
    var editingArea = false
    var nameAreaSelected = ""
    var timer: Timer?
    var polygonCurrent = MKPolygon()
    let notification = LocalNotification()
    lazy var pencil: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "pencil.circle"), style: .plain, target: self, action: #selector(pencilButtonAction))
    }()
    lazy var gearButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain , target: self, action: #selector(gearButtonAction))
    }()
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var sliderUiView: UIView!
    @IBOutlet weak var popUpAreaNameUiView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusAlertLabelStatus: UILabel!

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var monitoringButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameAreaTextField: UITextField!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var switchButtonRadiusAlert: UISwitch!
    
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        answerAuthorizations()
        initializeMapView()
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            hunter.area.coordinatesPoints.append(coordinate)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            hunter.area.coordinatesPoints.append(coordinate)
            mapView.addOverlay(hunter.area.createPolyLine())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        mapView.addOverlay(hunter.area.createPolygon())
        nameAreaTextField.becomeFirstResponder()
        editingArea = false
        popUpAreaNameUiView.isHidden = false
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if editingArea {
            turnOffEditingMode()
        }
        hunter.monitoring.monitoringIsOn = false
    }
    
    // MARK: - IBAction
    
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
    
    /// localize user
    @IBAction func locationButtonAction() {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    /// get name new area
    @IBAction func validateButtonAction() {
        guard let name = nameAreaTextField.text,  !name.isEmpty else {
            return
        }
        hunter.area.transfertAreaToFireBase(nameArea: name)
        turnOffEditingMode()
    }
    
    /// cancel new area
    @IBAction func cancelButtonAction() {
        turnOffEditingMode()
        mapView.removeOverlays(mapView.overlays)
    }
    
    /// define radius
    @IBAction func sliderAction() {
        radiusLabel.text = "\(Int(slider.value)) m"
        UserDefaults.standard.set(Int(slider.value), forKey: UserDefaultKeys.Keys.radiusAlert)
        insertRadius()
    }
    
    @IBAction func subtractButtonAction() {
        slider.value = slider.value - 1
        sliderAction()
    }
    
    @IBAction func addButtonAction() {
        slider.value = slider.value + 1
        sliderAction()
    }
    
    /// Start off monitoring
    @IBAction func monitoringAction() {
        if !hunter.monitoring.monitoringIsOn {
            monitoringOn()
        } else {
            monitoringOff()
        }
    }

    @objc func gearButtonAction() {
        settingsView.isHidden = !settingsView.isHidden
    }

    @IBAction func setAllowsNotificationRadiusAlertAction() {
        UserDefaults.standard.set(switchButtonRadiusAlert.isOn, forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
        radiusAlertLabelStatus.text = switchButtonRadiusAlert.isOn ? "Radius alert is enable" : "Radius alert is disable"
    }

    @objc func launchMonitoring() {
        checkIfUserIsInsideArea()
        checkIfOthersUsersAreInsideAreaAlert()
    }
    
    // MARK: - Private func
    private func initializeMapView() {
        switch mapMode {
        case .editingArea:
            navigationItem.rightBarButtonItem = pencil
            
        case .editingRadius:
            slider.value = Float(hunter.radiusAlert)
            radiusLabel.text = "\(Int(slider.value)) m"
            insertRadius()
            sliderUiView.backgroundColor = nil
            sliderUiView.isHidden = false
            
        case .monitoring:
            navigationItem.rightBarButtonItem = gearButton
            monitoringButton.isHidden = false
            settingsView.isHidden = true
            switchButtonRadiusAlert.isOn  = UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
            setAllowsNotificationRadiusAlertAction()
            monitoringButton.layer.cornerRadius = monitoringButton.layer.frame.height/2
        }

        notification.notificationInitialize()
        drawAreaSelected()
        setPopUpMessageNameArea()
        editingArea = false
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
    }
    
    private func setPopUpMessageNameArea() {
        popUpAreaNameUiView.layer.cornerRadius = 8
        popUpAreaNameUiView.isHidden = true
    }
    
    private func turnOffEditingMode() {
        popUpAreaNameUiView.isHidden = true
        nameAreaTextField.resignFirstResponder()
        hunter.area.coordinatesPoints = []
        mapView.isUserInteractionEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
        editingArea = false
    }

    private func drawAreaSelected() {
        var overlay: [String: MKOverlay] = [:]
        overlay.removeAll()

        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return
        }

        FirebaseManagement.shared.getArea(nameArea: nameAreaSelected, user: user) { result in
            switch result {
            case .success(let coordinate):
                overlay["polyLine"] = MKPolyline(coordinates: coordinate, count: coordinate.count)
                overlay["polygon"] = MKPolygon(coordinates: coordinate, count: coordinate.count)
                self.polygonCurrent = MKPolygon(coordinates: coordinate, count: coordinate.count)
                
                guard let polyLine = overlay["polyLine"], let polygon = overlay["polygon"] else {
                    return
                }
                self.mapView.addOverlay(polyLine)
                self.mapView.addOverlay(polygon)
                
                //define center map zoom
                if let center = overlay["polygon"]?.coordinate, self.mapMode == .editingArea {
                    let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                    let region = MKCoordinateRegion(center: center, span: span)
                    self.mapView.setRegion(region, animated: false)
                }
                
            case .failure(_):
                return
            }
        }
    }

    private func insertRadius() {
        let radius = CLLocationDistance(hunter.radiusAlert)
        guard let userPosition = locationManager.location?.coordinate else {
            return
        }
        removeRadiusOverlay()
        mapView.addOverlay(hunter.area.createCircle(userPosition: userPosition, radius: radius))
    }

    private func removeRadiusOverlay() {
        var overlay: MKOverlay?
        for element in  mapView.overlays {
            if element is MKCircle {
                overlay = element
            }
        }
        if let overlay = overlay {
            mapView.removeOverlay(overlay)
        }
    }
}

// MARK: - MapView delegate, CLLocation delegate
extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func answerAuthorizations() {
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if mapMode != .editingArea {
            mapView.setUserTrackingMode(.follow, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = UIColor.darkGray
            polyLineRenderer.lineWidth = 1
            return polyLineRenderer
            
        case is MKPolygon:
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = .red
            polygonView.alpha = 0.3
            return polygonView
            
        case is MKCircle:
            let circleView = MKCircleRenderer(overlay: overlay)
            circleView.fillColor = .red
            circleView.strokeColor = UIColor.blue
            circleView.lineWidth = 1
            circleView.alpha = 0.3
            return circleView
            
        default:
            return MKPolylineRenderer(overlay: overlay)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        hunter.meHunter.latitude = locations.first?.coordinate.latitude
        hunter.meHunter.longitude = locations.first?.coordinate.longitude
    }
}

// MARK: - Textfield delegate
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateButtonAction()
        return true
    }
}

// MARK: -Extension Monitoring
extension MapViewController {
    private func insertHunterInMap(_ arrayHunters: [Hunter]) {
        if arrayHunters.count > 0 {
            for hunter in arrayHunters {
                guard let latitude = hunter.meHunter.latitude, let longitude = hunter.meHunter.longitude else {
                    return
                }
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let showHunter = PlaceHunters(title: hunter.meHunter.displayName ?? "no name", coordinate: coordinate, subtitle: "Last view \(Date().getTime(dateInt: hunter.meHunter.date ?? 0))")
                mapView.addAnnotation(showHunter)
                mapView.register(AnnotationHuntersView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            }
            
        } else {
            removeRadiusOverlay()
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    private func monitoringOn() {
        let imageStop = UIImage(systemName: "stop.circle")
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(launchMonitoring), userInfo: nil, repeats: true)
        hunter.monitoring.monitoringIsOn = !hunter.monitoring.monitoringIsOn
        monitoringButton.setImage(imageStop, for: .normal)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func monitoringOff() {
        let imageStart = UIImage(systemName: "play.fill")
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        hunter.monitoring.monitoringIsOn = !hunter.monitoring.monitoringIsOn
        removeRadiusOverlay()
        mapView.removeAnnotations(mapView.annotations)
        monitoringButton.setImage(imageStart, for: .normal)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func checkIfUserIsInsideArea() {
        guard let positionUser = locationManager.location?.coordinate else {
            return
        }
        if !hunter.monitoring.checkUserIsAlwayInArea(area: polygonCurrent, positionUser: positionUser) {
            let banner = NotificationBanner(title: "Attention", subtitle: "You are exit of your area", leftView: nil, rightView: nil, style: .danger, colors: nil)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            notification.sendNotification()
            banner.show()
        }
    }
    
    private func checkIfOthersUsersAreInsideAreaAlert() {
        hunter.monitoring.CheckUserIsRadiusAlert(hunterSignIn: hunter) { [weak self] result in
            switch result {
            case .success(_):
                let allowsNotification = UserDefaults.standard.bool(forKey: UserDefaultKeys.Keys.allowsNotificationRadiusAlert)
                self?.mapView.removeAnnotations((self?.mapView.annotations)!)
                
                guard let arrayHunters = self?.hunter.monitoring.listHuntersInRadiusAlert else {
                    return
                }
                
                if arrayHunters.count > 0 {
                    self?.insertHunterInMap(arrayHunters)
                    self?.insertRadius()
                } else {
                    self?.removeRadiusOverlay()
                }

                if arrayHunters.count > 0, allowsNotification {
                    let bannerRadius = FloatingNotificationBanner(title: "Attention", subtitle: "Others users are near you", style: .info)
                    bannerRadius.show(cornerRadius: 8, shadowBlurRadius: 16)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    self?.notification.sendNotification()
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

