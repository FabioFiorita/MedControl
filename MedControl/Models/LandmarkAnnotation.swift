//
//  LandmarkAnnotation.swift
//  MedControl
//
//  Created by Fabio Fiorita on 20/01/21.
//

import MapKit
import UIKit


final class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(landmark: Landmark) {
        self.title = landmark.name
        self.coordinate = landmark.coordinate
    }
}

