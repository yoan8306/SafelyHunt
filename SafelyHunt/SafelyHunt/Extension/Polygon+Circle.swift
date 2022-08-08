//
//  Polygon+Circle.swift
//  SafelyHunt
//
//  Created by Yoan on 04/08/2022.
//

import Foundation
import MapKit
extension MKPolygon {
    func contain(coordinate: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
            return false
        } else {
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}

extension MKCircle {
    func contain(coordinate: CLLocationCoordinate2D) -> Bool {
        let circleRenderer = MKCircleRenderer(circle: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coordinate)
        let circleViewPoint: CGPoint = circleRenderer.point(for: currentMapPoint)
        if circleRenderer.path == nil {
            return false
        } else {
            return circleRenderer.path.contains(circleViewPoint)
        }
    }
}
