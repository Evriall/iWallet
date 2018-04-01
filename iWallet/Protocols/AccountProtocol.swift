//
//  AccountProtocol.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

protocol AccountProtocol {
    func handleCarrency(_ carrency: String)
    func handleAccountType(_ type: String)
}
