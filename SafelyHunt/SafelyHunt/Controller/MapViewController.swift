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
    var locationManager = CLLocationManager()
    var editingArea = false
    var editingRadius = false
    var createArea = Area()
    var nameAreaSelected = ""
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
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        setPopUpMessageNameArea()
        drawAreaSelected()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinateArea.append(coordinate)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard editingArea else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinateArea.append(coordinate)
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
        radiusLabel.text = "\(slider.value) m"
    }
    
    
// MARK: - Private func
    private func setPopUpMessageNameArea() {
        popUpAreaNameUiView.layer.cornerRadius = 8
        popUpAreaNameUiView.isHidden = true
    }
    
    private func turnOffEditingMode() {
        popUpAreaNameUiView.isHidden = true
        nameAreaTextField.resignFirstResponder()
        createArea.coordinateArea = []
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
                overlay["polygone"] = MKPolygon(coordinates: coordinate, count: coordinate.count)

                guard let polyLine = overlay["polyLine"], let polygone = overlay["polygone"] else {
                    return
                }

                if let center = overlay["polygone"]?.coordinate {
                    let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
                    let region = MKCoordinateRegion(center: center, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
                self.mapView.addOverlay(polyLine)
                self.mapView.addOverlay(polygone)
                
            case .failure(_):
                return
            }
        }
    }
}

// MARK: - MapView delegate, CLLocation delegate
extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func initializeMapView() {
        if editingArea {
            navigationItem.rightBarButtonItem = pencil
        }
        if editingRadius {
            sliderUiView.isHidden = false
        }

        sliderUiView.isHidden = true
        editingArea = false

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.setUserTrackingMode(.follow, animated: true)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.darkGray
            polylineRenderer.lineWidth = 1
            return polylineRenderer
            
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = .magenta
            polygonView.alpha = 0.3
            
            return polygonView
        }
        
        return MKPolylineRenderer(overlay: overlay)
    }
}

// MARK: - Textfield delegate
extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateButtonAction()
        return true
    }
}
