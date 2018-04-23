//
//  FourSquareService.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/20/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import MapKit

class FourSquareService {
    static let instance = FourSquareService()
    func getPlacesByCoordinates(longitude: Double, latitude: Double, radius: Int = 500, complition: @escaping (Bool)->()) {
        Alamofire.request("\(Constants.URL_FOURSQUARE)ll=\(latitude),\(longitude)&client_id=\(Constants.API_CLIENT_ID_FOURSQUARE)&client_secret=\(Constants.API_CLIENT_SECRET_FOURSQUARE)&intent=browse&radius=\(radius)&v=\(Date().fourSquareStr())", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.savePlaces(data: data, complition: { (success) in
                    complition(success)
                })
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
        
      
    }
    
    func getPlacesByName(name: String, longitude: Double, latitude: Double, complition: @escaping (Bool)->()) {
        Alamofire.request("\(Constants.URL_FOURSQUARE)ll=\(latitude),\(longitude)&client_id=\(Constants.API_CLIENT_ID_FOURSQUARE)&client_secret=\(Constants.API_CLIENT_SECRET_FOURSQUARE)&quary=\(name)&v=\(Date().fourSquareStr())", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.savePlaces(data: data, complition: { (success) in
                    complition(success)
                })
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
        
        
    }
    
    func savePlaces(data: Data,complition:@escaping  (Bool)->()) {
        let json = JSON(data)
        if let jsonResponse = json["response"].dictionary {
            if let jsonPlaces = jsonResponse["venues"]?.array {
                for items in jsonPlaces {
                    if let item = items.dictionary {
                        print(item.count)
                        guard let id  = item["id"]?.string, let name = item["name"]?.string, let location = item["location"]?.dictionary else {continue}
                        let address = location["address"]?.string ?? ""
                        guard let latitude = location["lat"]?.double, let longitude = location["lng"]?.double else {continue}
                        CoreDataService.instance.fetchPlaceById(id: id) { (places) in
                            if places.count > 0{
                                for place in places {
                                    place.name = name
                                    place.address = address
                                    place.latitude = latitude
                                    place.longitude = longitude
                                    CoreDataService.instance.update(complition: { (success) in
                                        if success {
                                            
                                        }
                                    })
                                }
                            } else {
                                CoreDataService.instance.savePlace(id: id, name: name, address: address, latitude: latitude, longitude: longitude, complition: { (success) in
                                    if success {
                                        
                                    }
                                })
                            }
                        }
                    }
                }
                complition(true)
            }else {
                complition(false)
            }
            
        } else {
            complition(false)
        }
    }
    
    func calculateCoordinatesWithRegion(location:CLLocation, distanceSpan: Double = 500.0) -> (start: CLLocationCoordinate2D, stop: CLLocationCoordinate2D)
    {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
        
        var start:CLLocationCoordinate2D = CLLocationCoordinate2D()
        var stop:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        start.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0)
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        stop.latitude   = region.center.latitude  - (region.span.latitudeDelta  / 2.0)
        stop.longitude  = region.center.longitude + (region.span.longitudeDelta / 2.0)
        
        return (start, stop)
    }
}
