//
//  MapVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/7/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var infoLbl: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    var date = Date()
    private var currentCalendar: Calendar?
    var places = [MapPlace]()
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
        self.mapView.delegate = self
        self.mapView.register(MapPlaceMarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//        self.mapView.register(MapPlaceView.self,
//                              forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        setMonthLabel()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    
    func fetchData(){
        places = []
        var pairCurrency = ""
        CoreDataService.instance.fetchPlacesIncome(ByDate: date) { (fetchedPlaces) in
            for item in fetchedPlaces {
                if pairCurrency.isEmpty {
                    pairCurrency = item.currency
                }
                if self.places.contains(where: { (place) -> Bool in
                    place.place == item.place
                }) {
                    for place in self.places {
                        if place.place == item.place{
                            place.income.append("\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency))
                            if pairCurrency != item.currency {
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: item.currency, pairCode: pairCurrency, complition: { (rate) in
                                    place.evaluationOfTurnoverAtExchangeRate += item.amount * rate
                                })
                            } else {
                                place.evaluationOfTurnoverAtExchangeRate += item.amount
                            }
                        }
                    }
                } else {
                    if pairCurrency != item.currency {
                        ExchangeService.instance.fetchLastCurrencyRate(baseCode: item.currency, pairCode: pairCurrency, complition: { (rate) in
                            self.places.append(MapPlace(place: item.place, income: ["\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency)], costs: [], latitude: item.latitude, longitude: item.longitude, turnover: item.amount*rate))
                        })
                    } else {
                        self.places.append(MapPlace(place: item.place, income: ["\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency)], costs: [], latitude: item.latitude, longitude: item.longitude, turnover: item.amount))
                    }
                    
                    
                }
            }
            CoreDataService.instance.fetchPlacesCosts(ByDate: date, complition: { (fetchedPlaces) in
                if fetchedPlaces.count > 0 {
                    for (index,item) in fetchedPlaces.enumerated() {
                        if pairCurrency.isEmpty {
                            pairCurrency = item.currency
                        }
                        if self.places.contains(where: { (place) -> Bool in
                            place.place == item.place
                        }) {
                            for place in self.places {
                                if place.place == item.place{
                                    place.costs.append("\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency))
                                    if pairCurrency != item.currency{
                                        ExchangeService.instance.fetchLastCurrencyRate(baseCode: item.currency, pairCode: pairCurrency, complition: { (rate) in
                                            place.evaluationOfTurnoverAtExchangeRate += item.amount * rate
                                            if index == fetchedPlaces.count - 1 {
                                                self.setUpMapView()
                                            }
                                        })
                                    } else {
                                        place.evaluationOfTurnoverAtExchangeRate += item.amount
                                        if index == fetchedPlaces.count - 1 {
                                            self.setUpMapView()
                                        }
                                    }
                                }
                            }
                        } else {
                            if pairCurrency != item.currency{
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: item.currency, pairCode: pairCurrency, complition: { (rate) in
                                    self.places.append(MapPlace(place: item.place, income: [], costs: ["\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency)], latitude: item.latitude, longitude: item.longitude, turnover: item.amount * rate))
                                    if index == fetchedPlaces.count - 1 {
                                        self.setUpMapView()
                                    }
                                })
                            } else {
                                self.places.append(MapPlace(place: item.place, income: [], costs: ["\(item.amount.roundTo(places: 2))" + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: item.currency)], latitude: item.latitude, longitude: item.longitude, turnover: item.amount))
                                if index == fetchedPlaces.count - 1 {
                                    self.setUpMapView()
                                }
                            }
                        }
                    }
                } else {
                    setUpMapView()
                }
            })
        }
    }
    
    func setUpMapView(){
        self.places.sort(by: { (arg0, arg1) -> Bool in
            arg0.evaluationOfTurnoverAtExchangeRate > arg1.evaluationOfTurnoverAtExchangeRate
        })
        for (index,item) in self.places.enumerated() {
            item.number = index + 1
        }
        if self.places.count > 0 {
            mapView?.isHidden = false
            infoLbl.isHidden = true
        } else {
            mapView?.isHidden = true
            infoLbl.isHidden = false
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.centerMapOnLocation()
        self.mapView.addAnnotations(self.places)
        for item in self.mapView.annotations{
            if let annotation = item as? MapPlace, annotation.number == 1 {
                self.mapView.selectAnnotation(item, animated: true)
            }
        }
    }
    
    func centerMapOnLocation() {
        var coordinateRegion: MKCoordinateRegion?
        if self.places.count > 0 {
            var minLongitude = self.places[0].coordinate.longitude
            var maxLongitude = self.places[0].coordinate.longitude
            var minLatitude = self.places[0].coordinate.latitude
            var maxLatitude = self.places[0].coordinate.latitude
            for item in self.places {
                if item.coordinate.longitude < minLongitude {
                    minLongitude = item.coordinate.longitude
                }
                if item.coordinate.longitude > maxLongitude {
                    maxLongitude = item.coordinate.longitude
                }
                if item.coordinate.latitude < minLatitude {
                    minLatitude = item.coordinate.latitude
                }
                if item.coordinate.latitude > maxLatitude {
                    maxLatitude = item.coordinate.latitude
                }
            }
            if minLatitude == maxLatitude || minLongitude == maxLongitude {
                coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude), regionRadius, regionRadius)
            } else {
                let center = CLLocationCoordinate2D(latitude: maxLatitude - ((maxLatitude - minLatitude) / 2), longitude: maxLongitude - ((maxLongitude -  minLongitude) / 2))
                var latitudeDistance = CLLocation(latitude: minLatitude, longitude: minLongitude).distance(from: CLLocation(latitude: maxLatitude, longitude: minLongitude))
                latitudeDistance += latitudeDistance * 0.2
                var longitudeDistance = CLLocation(latitude: minLatitude, longitude: minLongitude).distance(from: CLLocation(latitude: minLatitude, longitude: maxLongitude))
                longitudeDistance += longitudeDistance * 0.2
                coordinateRegion = MKCoordinateRegionMakeWithDistance(center, latitudeDistance, longitudeDistance)
            }
            if let coordinateRegion = coordinateRegion {
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
    func setMonthLabel(){
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: date, calendar: currentCalendar).globalDescription
        }
    }
    
    @IBAction func forwardBtnPressed(_ sender: Any) {
        date = date.nextMonth()
        setMonthLabel()
        fetchData()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        date = date.previousMonth()
        setMonthLabel()
        fetchData()
    }
}

extension MapVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        if let location = view.annotation as? MapPlace {
            let placeDetailsVC = PlaceDetailsVC()
            placeDetailsVC .modalPresentationStyle = .custom
            placeDetailsVC.mapPlace = location
            presentDetail(placeDetailsVC)
        }
        
    }
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? MapPlace else { return nil }
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
}
