//
//  GlobeMapCoordinateConverter.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import Foundation
import MapKit

class GlobeMapCoordinateConverter {

    static let shared = GlobeMapCoordinateConverter()
    private init() {}

    weak var mapView: MKMapView?

    func convert(point: CGPoint) -> CLLocationCoordinate2D {
        guard let mapView = mapView else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        return mapView.convert(point, toCoordinateFrom: mapView)
    }

}

