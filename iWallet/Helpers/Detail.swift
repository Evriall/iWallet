//
//  Detail.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/10/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
class Detail {
}

class DateDetail: Detail {
    var amount: Double = 0.0
    var name: String
    init(name: String) {
        self.name = name
    }
    init(name: String, amount: Double) {
        self.name = name
        self.amount = amount
    }
    
}
class AccountDetail : Detail{
    var amount: Double = 0.0
    var name: String
    var currencySymbol: String
    init(name: String, amount: Double, currencySymbol: String){
        self.currencySymbol = currencySymbol
        self.name = name
        self.amount = amount
    }
}

class TransactionDetail: Detail {
    var transaction: Transaction
    init(transaction: Transaction) {
        self.transaction = transaction
    }
}
