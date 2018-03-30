//
//  TransactionHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

enum TransactionType: String {
    case expance = "expence"
    case income = "income"
    case transfer = "transfer"
}

class TransactionHelper {
    static let instance = TransactionHelper()
    private let defaults  = UserDefaults.standard
    var currentType: String? {
        get {
            return defaults.string(forKey: Constants.CURRENT_TRANSACTION_TYPE)
        }
        set {
            defaults.set(newValue, forKey: Constants.CURRENT_TRANSACTION_TYPE)
        }
    }
}
