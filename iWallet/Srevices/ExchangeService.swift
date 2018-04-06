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
    
    func getCurrencyRate(complition: @escaping (Bool)->()) {
        Alamofire.request("\(Constants.URL_CURRENCY_EXCHANGE_RATE)\(Constants.API_KEY_CURRENCY_EXCHANGE_RATE)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.setExchangeRate(data: data, complition: { (success) in
                    complition(success)
                })
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
    }
    
    func setEuroExchangeRate(rates: [String : Double]){
        let base = Constants.EUR
        for (currencyName, rate) in rates {
            CoreDataService.instance.fetchCurrencyRate(base: base, pair: currencyName) { (currencyRates) in
                if currencyRates.count > 0 {
                    for item in currencyRates {
                        item.rate = rate
                        CoreDataService.instance.update(complition: { (success) in
                            if success {
                                
                            }
                        })
                    }
                } else {
                    CoreDataService.instance.saveCurrencyRate(base: base, pair: currencyName, rate: rate)
                }
            }
        }
        
        CoreDataService.instance.fetchCurrencyRate(base: base, pair: base) { (currencyRates) in
            if currencyRates.count == 0 {
                CoreDataService.instance.saveCurrencyRate(base: base, pair: base, rate: 1.0)
            }
        }
        
    }
    
    func setExchangeRate(byBaseCurrency base: String, rates: [String: Double]){
        guard let rateToEur = rates[base] else {return}
        for (currencyName, rate) in rates {
            CoreDataService.instance.fetchCurrencyRate(base: base, pair: currencyName) { (currencyRates) in
                if currencyRates.count > 0 {
                    for item in currencyRates {
                        item.rate = rate / rateToEur
                        CoreDataService.instance.update(complition: { (success) in
                            if success {
                                
                            }
                        })
                    }
                } else {
                    CoreDataService.instance.saveCurrencyRate(base: base, pair: currencyName, rate: rate / rateToEur)
                }
            }
        }
    }
    
    func setExchangeRate(data: Data,complition:@escaping  (Bool)->()) {
        let json = JSON(data)
        var euroRates = [String: Double]()
        if let jsonRates = json["rates"].dictionary {
            for (currencyName, rate) in jsonRates {
                euroRates[currencyName] = rate.double
            }
        }
        CoreDataService.instance.fetchCurrencies { (currencies) in
            for item in currencies {
                if item == Constants.EUR {
                    setEuroExchangeRate(rates: euroRates)
                } else {
                    setExchangeRate(byBaseCurrency: item, rates: euroRates)
                }
            }
            complition(true)
        }
    }
    
    func checkCurrencyRateExistanceForAllCurrency() -> Bool {
        var result = true
        CoreDataService.instance.fetchCurrencies(complition: { (currencies) in
            if currencies.count > 0 {
                for item in currencies {
                    CoreDataService.instance.fetchCurrencyRates(base: item, complition: { (currencyRates) in
                        if currencyRates.count == 0 {
                            result = false
                        }
                    })
                }
            }
        })
        return result
    }
}
