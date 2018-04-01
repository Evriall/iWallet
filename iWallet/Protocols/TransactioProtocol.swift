//
//  TransactioProtocol.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/1/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

protocol TransactionProtocol {
    func handleTransactionType(_ type: String)
}
