//
//  TransactionHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

enum TransactionType: String {
    case costs = "Costs"
    case income = "Income"
    case transfer = "Transfer"
    static let allValues = [costs, income, transfer]
}

class TransactionHelper {
    static let instance = TransactionHelper()
    private let defaults  = UserDefaults.standard
    var currentType: String {
        get {
            return defaults.string(forKey: Constants.CURRENT_TRANSACTION_TYPE) ?? TransactionType.costs.rawValue
        }
        set {
            defaults.set(newValue, forKey: Constants.CURRENT_TRANSACTION_TYPE)
        }
    }
    func getTransactionDescription(transaction: Transaction) -> String{
        var description = ""
        if let transfer = transaction.transfer {
            guard let nameTransactionFrom = transaction.account?.name else {return ""}
            guard let nameTransactionTo = transfer.account?.name else {return ""}
            guard let transactionType = transaction.type else {return ""}
            if transactionType == TransactionType.costs.rawValue {
                description = "\(nameTransactionFrom) → \(nameTransactionTo)"
            } else {
                description = "\(nameTransactionTo) → \(nameTransactionFrom)"
            }
        } else if let place = transaction.place {
            description = place.name ?? ""
        }
        return description
    }
}
