//
//  AccountHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/28/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

enum AccountType : String {
    case Cash = "Cash"
    case DebitCard = "Debit card"
    case CreditCard = "Credit card"
    case ElectronicWallet = "Electronic wallet"
    static let allValues = [Cash, DebitCard, CreditCard, ElectronicWallet]
}

class AccountHelper{
    static let instance = AccountHelper()
    private let defaults  = UserDefaults.standard
    var currentAccount: String?{
        get {
            return defaults.string(forKey: Constants.CURRENT_ACCOUNT)
        }
        set {
            defaults.set(newValue, forKey: Constants.CURRENT_ACCOUNT)
        }
    }
    
    
    func getLocaleCarrencySymbolAndCode() -> (symbol: String, code: String) {
        let locale = Locale.current
        guard let currencySymbol = locale.currencySymbol else {return ("$","USD")}
        guard let currencyCode = locale.currencyCode else {return ("$","USD")}
        return (currencySymbol, currencyCode)
    }
    
    func getCurrencySymbol(byCurrencyCode currencyCode: String) -> String {
        let currSymbol = Locale.availableIdentifiers.map{ Locale(identifier: $0)}.filter { return currencyCode == $0.currencyCode }.map { ($0.identifier, $0.currencySymbol) }.flatMap {$0}.first
        return currSymbol?.1 ?? currencyCode
    }
    
    func initPersonalAccount(_ complition: (Bool)->()){
        CoreDataService.instance.saveAccount(name: "Cash", type: AccountType.Cash.rawValue, currency: getLocaleCarrencySymbolAndCode().code) { (success) in
            if success {
                complition(success)
            } else {
                complition(success)
                print("Can`t create account")
            }
        }
    }
    
    func evaluateBalance(byAccount: Account? = nil, complition: (Double)->()){
        CoreDataService.instance.evaluateAllIncome(byAccount: byAccount) { (incomeSum) in
            CoreDataService.instance.evaluateAllCosts(byAccount: byAccount, complition: { (costsSum) in
                complition(incomeSum - costsSum)
            })
        }
        
    }
    
    
    func initExternalAccount(){
        CoreDataService.instance.saveAccount(name: Constants.NAME_FOR_EXTERNAL_ACCOUNT, type: AccountType.DebitCard.rawValue, currency: getLocaleCarrencySymbolAndCode().code, external: true) { (success) in
            if !success {
                print("Can`t create account")
            }
        }
    }
    
    
}
