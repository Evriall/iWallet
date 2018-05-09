//
//  MapPlace.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/8/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import MapKit

class MapPlace: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var place: String
    var income: [String]
    var costs: [String]
    var evaluationOfTurnoverAtExchangeRate = 0.0
    var number = 0
    
    init(place: String, income: [String], costs: [String], latitude: Double, longitude: Double, turnover: Double) {
        self.place = place
        self.income = income
        self.costs = costs
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.evaluationOfTurnoverAtExchangeRate = turnover
        super.init()
    }
    var title: String? {
        return place
    }
    var subtitle: String? {
        var strIncome = ""
        var strCosts = ""
        var str = ""
        for item in income {
            strIncome += item + ", "
        }
        if !strIncome.isEmpty {
            strIncome = "Income: \(strIncome.dropLast(2))"
        }
        for item in costs {
            strCosts += item + ", "
        }
        if !strCosts.isEmpty {
            strCosts = "Costs: \(strCosts.dropLast(2))"
        }
        if !strIncome.isEmpty && !strCosts.isEmpty {
            str = strIncome + "\n" + strCosts
        } else if !strIncome.isEmpty {
            str = strIncome
        } else if !strCosts.isEmpty{
            str = strCosts
        }
        return str
    }
}
