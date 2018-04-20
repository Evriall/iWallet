//
//  SelectPlaceVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/20/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class SelectPlaceVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: PlaceProtocol?
    var location: CLLocation?
    var locationManager = CLLocationManager()
    var nearestPlaces = [Place]()
    var lastPlaces = [Place]()
    var showNearestPlaces = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlaceCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
}

extension SelectPlaceVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showNearestPlaces {
            return nearestPlaces.count
        } else {
            return lastPlaces.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell {
            let place = showNearestPlaces ? nearestPlaces[indexPath.row] : lastPlaces[indexPath.row]
            cell.configureCell(title: place.name, subtitle: place.address)
            return cell
        }
        return PlaceCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = showNearestPlaces ? nearestPlaces[indexPath.row] : lastPlaces[indexPath.row]
        delegate?.handlePlace(place)
        dismissDetail()
    }
}

extension SelectPlaceVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
            if NetworkReachabilityManager()!.isReachable {
                FourSquareService.instance.getPlacesByCoordinates(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, radius: Constants.REGION_SIZE_FOURSQUARE ) { (success) in
                    if success {
                        let (start, stop) = FourSquareService.instance.calculateCoordinatesWithRegion(location: location, distanceSpan: Double(Constants.REGION_SIZE_FOURSQUARE))
                        CoreDataService.instance.fetchPlacesByLocationRegion(startLatitude: start.latitude, endLatitude: stop.latitude, startLongitude: start.longitude, endLongitude: stop.longitude, complition: { (places) in
                            print("CoreData: ", places.count)
                            self.nearestPlaces = places
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            } else {
                let (start, stop) = FourSquareService.instance.calculateCoordinatesWithRegion(location: location, distanceSpan: Double(Constants.REGION_SIZE_FOURSQUARE))
                CoreDataService.instance.fetchPlacesByLocationRegion(startLatitude: start.latitude, endLatitude: stop.latitude, startLongitude: start.longitude, endLongitude: stop.longitude, complition: { (places) in
                    self.nearestPlaces = places
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "In order to fetch places we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
