//
//  PlaceHunters.swift
//  SafelyHunt
//
//  Created by Yoan on 06/08/2022.
//

import Foundation
import MapKit

class PlaceHunters: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
}
