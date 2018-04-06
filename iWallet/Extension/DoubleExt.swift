//
//  DoubleExt.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/6/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
