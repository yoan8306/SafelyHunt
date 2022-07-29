//
//  MapViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 29/07/2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }
    
    @IBAction func locationButtonAction() {
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        locationManager.allowsBackgroundLocationUpdates = true
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
