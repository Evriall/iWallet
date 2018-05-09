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
    
    func getStartPosition(str: String, subStr: String)->Int? {
        if let range = str.lowercased().range(of: subStr) {
            let startPos = str.distance(from: str.startIndex, to: range.lowerBound)
            return startPos
        }
        return nil
    }
    
    func getEndPosition(str: String, subStr: String)->Int? {
        if let range = str.lowercased().range(of: subStr) {
            let endPos = str.distance(from: str.startIndex, to: range.upperBound)
            return endPos
        }
        return nil
    }
    
    func getHistoricalCurrencyRate(date: Date, currencies: [String], complition: @escaping (Bool)->()){
        if currencies.count == 0 {
            complition(false)
            return
        }
        var currencies = currencies
        if let index = currencies.index(of: Constants.EUR) {
            currencies.remove(at: index)
        }
        let pairs = currencies.joined(separator: ",")
        Alamofire.request("\(Constants.URL_CURRENCY_EXCHANGE_RATE_HISTORICAL)\(date.fixerStr())?access_key=\(Constants.API_KEY_CURRENCY_EXCHANGE_RATE)&base=\(Constants.EUR)&symbols=\(pairs)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.HEADER).responseJSON{ (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                self.saveExchangeRate(data: data, date: date, complition: { (success) in
                    complition(success)
                })
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
    }
    
    func getHistoricalCurrencyRate(date: Date, complition: @escaping (Bool)->()) {
        CoreDataService.instance.fetchCurrenciesFromCurrencyRate { (currencies) in
            if currencies.count == 0 {
                CoreDataService.instance.fetchCurrenciesFromAccount { (currencies) in
                    ExchangeService.instance.getHistoricalCurrencyRate(date: date, currencies: currencies, complition: { (success) in
                        complition(success)
                    })
                }
            } else {
                    ExchangeService.instance.getHistoricalCurrencyRate(date: date, currencies: currencies, complition: { (success) in
                        complition(success)
                })
            }
        }
        
        
    }
    
    func fetchLastCurrencyRate(baseCode: String, pairCode: String, complition: @escaping (Double)->()){
        let result = 1.0
        CoreDataService.instance.fetchLastCurrencyRate(base: baseCode, pair: pairCode) { (currencyRates) in
            if currencyRates.count > 0 {
                if let currencyRate = self.evaluateCurrencyRate(base: baseCode, pair: pairCode, rates: currencyRates) {
                    complition(currencyRate)
                } else {
                    print("Can`t evaluate currency rate for \(baseCode):\(pairCode)")
                    complition(result)
                }
            } else {
                complition(result)
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
    
    func saveExchangeRate(data: Data, date: Date = Date(),complition:@escaping  (Bool)->()) {
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
                CoreDataService.instance.saveCurrencyRate(base: base, pair: currencyName, rate: rate, date: date, complition:{ (success) in
                })
            }
            CoreDataService.instance.saveCurrencyRate(base: Constants.EUR, pair: Constants.EUR, rate: 1.0, date: date, complition:{ (success) in
                if success {
                    complition(true)
                }
            })
            
        } else {
            complition(false)
        }
    }
}
