//
//  MapPlaceView.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/8/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import MapKit

class MapPlaceView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let mapPlace = newValue as? MapPlace else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            image = UIImage(named: "PinIconRoundedDark")
        }
    }
}
