//
//  MapPlaceMarkerView.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/8/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import MapKit

class MapPlaceMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let mapPlace = newValue as? MapPlace else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            glyphText = String(mapPlace.number)
                if  mapPlace.income.count > 0 && mapPlace.costs.count > 0 {
                    markerTintColor =   #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
//                    glyphImage = UIImage(named: "ArrowUpDownIcon")
                   
                } else if mapPlace.income.count > 0 {
                    markerTintColor =   #colorLiteral(red: 0, green: 0.8566937114, blue: 0.8730384864, alpha: 1)
//                    glyphImage = UIImage(named: "ArrowDownIcon")
                } else {
                    markerTintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.5764705882, alpha: 1)
//                    glyphImage = UIImage(named: "ArrowUpIcon")
                }
            let subtitleView = UILabel()
            subtitleView.font = subtitleView.font.withSize(12)
            subtitleView.numberOfLines = 0
            subtitleView.text = mapPlace.subtitle
            
           detailCalloutAccessoryView = subtitleView
            
            let mapsButton = ButtonWithRoundCoreners(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "WalletIcon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
        }
    }
}
