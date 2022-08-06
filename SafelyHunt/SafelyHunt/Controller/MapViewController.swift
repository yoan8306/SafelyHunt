//
//  MapViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import UIKit
import MapKit
import FirebaseAuth

class MapViewController: UIViewController {
    // MARK: - Properties
    var hunter = Hunter()
    var locationManager = CLLocationManager()
    var mapMode: MapMode = .monitoring
    var editingArea = false
    var createArea = Area()
    var nameAreaSelected = ""
    var timer: Timer?
    var counter = 0
    lazy var pencil: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "pencil.circle"), style: .plain, target: self, action: #selector(pencilButtonAction))
    }()
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var sliderUiView: UIView!
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var nameAreaTextField: UITextField!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var popUpAreaNameUiView: UIView!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var monitoringButton: UIButton!
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        drawAreaSelected()
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinatesPoints.append(coordinate)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinatesPoints.append(coordinate)
            mapView.addOverlay(createArea.createPolyLine())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        mapView.addOverlay(createArea.createPolygon())
        nameAreaTextField.becomeFirstResponder()
        editingArea = false
        popUpAreaNameUiView.isHidden = false
    }
    
    // MARK: - IBAction
  @objc func pencilButtonAction() {
        if !editingArea {
            navigationController?.navigationBar.backgroundColor = .red
            mapView.removeOverlays(mapView.overlays)
            mapView.isUserInteractionEnabled = false
            editingArea  = true
            myNavigationItem.title = "Draw area with finger"
        } else {
            let test = Monitoring()
            test.getPosition()
            turnOffEditingMode()
        }
    }
    
    @IBAction func locationButtonAction() {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    @IBAction func validateButtonAction() {
        guard let name = nameAreaTextField.text,  !name.isEmpty else {
            return
        }
        createArea.transfertAreaToFireBase(nameArea: name)
        turnOffEditingMode()
    }
    
    @IBAction func cancelButtonAction() {
        turnOffEditingMode()
        mapView.removeOverlays(mapView.overlays)
    }
    
    @IBAction func sliderAction() {
        radiusLabel.text = "\(Int(slider.value)) m"
        insertRadius()
        UserDefaults.standard.set(Int(slider.value), forKey: UserDefaultKeys.Keys.radiusAlert)
    }
    
    @IBAction func monitoringAction() {
        let imageStop = UIImage(systemName: "stop.circle")
        let imageStart = UIImage(systemName: "play.fill")
        if !hunter.monitoring {
            monitoringButton.setImage(imageStop, for: .normal)
            monitoring()
        } else {
            timer?.invalidate()
            monitoringButton.setImage(imageStart, for: .normal)
        }
    }
    
// MARK: - Private func
    private func setPopUpMessageNameArea() {
        popUpAreaNameUiView.layer.cornerRadius = 8
        popUpAreaNameUiView.isHidden = true
    }
    
    private func turnOffEditingMode() {
        popUpAreaNameUiView.isHidden = true
        nameAreaTextField.resignFirstResponder()
        createArea.coordinatesPoints = []
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

                guard let polyLine = overlay["polyLine"], let polygon = overlay["polygon"] else {
                    return
                }
                self.mapView.addOverlay(polyLine)
                self.mapView.addOverlay(polygon)
                
                //define center map zoom
                if let center = overlay["polygon"]?.coordinate, self.mapMode == .editingArea {
                    let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                    let region = MKCoordinateRegion(center: center, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
                
            case .failure(_):
                return
            }
        }
    }
    
    private func insertRadius() {
        mapView.removeOverlays(mapView.overlays)
        guard let userPosition = locationManager.location?.coordinate else {
            return
        }
        let radius = CLLocationDistance(slider.value)
        mapView.addOverlay(createArea.createCircle(userPosition: userPosition, radius: radius))
    }
    
}

// MARK: - MapView delegate, CLLocation delegate
extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func initializeMapView() {
        switch mapMode {
        case .editingArea:
            navigationItem.rightBarButtonItem = pencil
        case .editingRadius:
            slider.value = Float(UserDefaults.standard.integer(forKey:UserDefaultKeys.Keys.radiusAlert))
            radiusLabel.text = "\(Int(slider.value)) m"
            insertRadius()
            sliderUiView.backgroundColor = nil
            sliderUiView.isHidden = false
        case .monitoring:
            monitoringButton.isHidden = false
        }
        setPopUpMessageNameArea()
        editingArea = false
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.setUserTrackingMode(.follow, animated: true)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = UIColor.darkGray
            polyLineRenderer.lineWidth = 1
            return polyLineRenderer
            
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = .red
            polygonView.alpha = 0.3
            
            return polygonView
        } else if overlay is MKCircle {
            let circleView = MKCircleRenderer(overlay: overlay)
            circleView.fillColor = .red
            circleView.strokeColor = UIColor.blue
            circleView.lineWidth = 1
            circleView.alpha = 0.3
            return circleView
        }
        
        return MKPolylineRenderer(overlay: overlay)
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
    
// MARK: - Monitoring
extension MapViewController {
        private func monitoring() {
            locationManager.startUpdatingLocation()
            timer = Timer.scheduledTimer(timeInterval: 15, target: self,
                                         selector: #selector(getPositionOthersHunter), userInfo: nil, repeats: true)
        }
    
    @objc func getPositionOthersHunter() {
        
        guard let latitude = locationManager.location?.coordinate.latitude, let longitude = locationManager.location?.coordinate.longitude else {
            return
        }
        let myPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
        hunter.updatePosition(userPostion: myPosition)
            FirebaseManagement.shared.getPositionUsers {[weak self] result in
                switch result {
                case .success(let hunters):
                    self?.mapView.removeAnnotations((self?.mapView.annotations)!)
                    self?.counter = 0
                    self?.hunter.others = hunters
                    self?.hunter.getHuntersInRadiusAlert()
                    guard let huntersInRadius = self?.hunter.hunterInRadiusAlert else {
                        return
                    }
                    
                    if huntersInRadius.count > 0 {
                        for hunter in huntersInRadius {
                            guard let latitude = hunter.meHunter.latitude, let longitude = hunter.meHunter.longitude else {
                                return
                            }
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let showHunter = PlaceHunters(title: hunter.meHunter.displayName ?? "no name", coordinate: coordinate, subtitle: Date().relativeDate(dateInt: hunter.meHunter.date ?? 0))
                            self?.mapView.addAnnotation(showHunter)
                            
                        }
                    }
                    
                case .failure(_):
                    print("")
                    self?.counter = 0
                }
            }
        }
    
    
    
    
}

