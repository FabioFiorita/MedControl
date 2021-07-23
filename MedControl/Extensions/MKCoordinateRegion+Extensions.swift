//
//  MKCoordinateRegion+Extensions.swift
//  MedControl
//
//  Created by Fabio Fiorita on 22/07/21.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    
    static var defaultRegion: MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 29.726819, longitude: -95.393692), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
    
}
