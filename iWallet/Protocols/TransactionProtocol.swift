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
    func handleAccountFrom(_ account: Account)
    func handleAccountTo(_ account: Account)
    func handleAdditionalInfo(place: Place?, desc: String, date: Date, tags: [(name: String, selected: Bool)], photos: [[String: UIImage]])
}
