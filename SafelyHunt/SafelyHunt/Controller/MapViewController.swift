//
//  MapViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
// MARK: - Properties
    var locationManager = CLLocationManager()
    var modeEditingMap = false
    var createArea = Area()

// MARK: - IBOutlet
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameAreaTextField: UITextField!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    @IBOutlet weak var popUpAreaNameUiView: UIView!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    

// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        setPopUpMessageNameArea()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard modeEditingMap else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinateArea.append(coordinate)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard modeEditingMap else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            createArea.coordinateArea.append(coordinate)
            mapView.addOverlay(createArea.createPolyLine())
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard modeEditingMap else {
            return
        }
        mapView.addOverlay(createArea.createPolygon())
        nameAreaTextField.becomeFirstResponder()
        modeEditingMap = false
        popUpAreaNameUiView.isHidden = false
    }

// MARK: - IBAction
    @IBAction func pencilButtonAction(_ sender: UIBarButtonItem) {
        if !modeEditingMap {
            navigationController?.navigationBar.backgroundColor = .red
            mapView.isUserInteractionEnabled = false
            modeEditingMap  = true
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

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if modeEditingMap {
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
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    private func setPopUpMessageNameArea() {
        popUpAreaNameUiView.layer.cornerRadius = 8
        popUpAreaNameUiView.isHidden = true
    }
    
    private func turnOffEditingMode() {
        popUpAreaNameUiView.isHidden = true
        nameAreaTextField.resignFirstResponder()
        createArea.coordinateArea = []
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        mapView.isUserInteractionEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
        modeEditingMap = false
    }
    
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    private func initializeMapView() {
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
}

extension MapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validateButtonAction()
        return true
    }
}
