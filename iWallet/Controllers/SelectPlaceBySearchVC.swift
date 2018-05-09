//
//  SelectPlaceBySearchVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/23/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class SelectPlaceBySearchVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var location: CLLocation?
    var places = [Place]()
    var delegate : PlaceProtocol?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PlaceCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        activity.startAnimating()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismissDetail()
    }
}
extension SelectPlaceBySearchVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell {
            let place = places[indexPath.row]
            cell.configureCell(title: place.name, subtitle: place.address)
            return cell
        }
        return PlaceCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.handlePlace(places[indexPath.row])
        dismissDetail()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let address = places[indexPath.row].address, !address.isEmpty
        {
            return CGFloat(50)
        }
        return CGFloat(30)
        
    }
    
    func fetchData(){
        if let searchText = searchBar.text, !searchText.isEmpty {
            tableView.isHidden = false
            bgView.alpha = 1
            if NetworkReachabilityManager()!.isReachable {
                if let location = self.location {
                    FourSquareService.instance.getPlacesByName(name: searchText, longitude: location.coordinate.longitude, latitude: location.coordinate.latitude) { (success) in
                        if success {
                            CoreDataService.instance.fetchPlace(ByName: searchText) { (places) in
                                self.places = places
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else {
                    CoreDataService.instance.fetchPlace(ByName: searchText) { (places) in
                        self.places = places
                        self.tableView.reloadData()
                    }
                }
            } else {
                CoreDataService.instance.fetchPlace(ByName: searchText) { (places) in
                    self.places = places
                    self.tableView.reloadData()
                }
            }
            
        } else {
            tableView.isHidden = true
            places = []
            bgView.alpha = 0.3
            tableView.reloadData()
        }
    }
}

extension SelectPlaceBySearchVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       fetchData()
    }
}

extension SelectPlaceBySearchVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            locationManager.stopUpdatingLocation()
            activity.stopAnimating()
            activity.isHidden = true
            fetchData()
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
    
    func showInternetConnectionIsNotReachable() {
        let alertController = UIAlertController(title: "No Internet connection",
                                                message: "Try to reconnect",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open WIFI Settings", style: .default) { (action) in
            if let url = URL(string: "prefs:root=WIFI") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
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
