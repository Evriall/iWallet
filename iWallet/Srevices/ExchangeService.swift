//
//  ExchangeService.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/6/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ExchangeService{
    static let instance = ExchangeService()
    
    func getCurrencyRateByAPILatest(complition: @escaping (Bool)->()) {
        Alamofire.request("\(Constants.URL_CURRENCY_EXCHANGE_RATE)\(Constants.API_KEY_CURRENCY_EXCHANGE_RATE)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.saveExchangeRate(data: data, complition: { (success) in
                    complition(success)
                })
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
    }

    
    func evaluateCurrencyRate(base: String, pair: String, rates: [CurrencyRate]) -> (Double?){
        var baseRate = 0.0
        var pairRate = 0.0
        for item in rates {
            if item.pair == base {
                baseRate = item.rate
            }
            if item.pair == pair {
                pairRate = item.rate
            }
        }
        if baseRate == 0.0 || pairRate == 0.0 {
            return nil
        }
        return pairRate / baseRate
    }
    
    func saveExchangeRate(data: Data,complition:@escaping  (Bool)->()) {
        let base = Constants.EUR
        let json = JSON(data)
        var euroRates = [String: Double]()
        if let jsonRates = json["rates"].dictionary {
            for (currencyName, rate) in jsonRates {
                euroRates[currencyName] = rate.double
            }
        }
        if euroRates.count > 0 {
            for (currencyName, rate) in euroRates {
                CoreDataService.instance.saveCurrencyRate(base: base, pair: currencyName, rate: rate, date: Date(), complition:{ (success) in
                    if success {
                    }
                })
            }
            CoreDataService.instance.saveCurrencyRate(base: base, pair: base, rate: 1.0, date: Date(), complition:{ (success) in
                complition(success)
            })
        } else {
            complition(false)
        }
    }
}
