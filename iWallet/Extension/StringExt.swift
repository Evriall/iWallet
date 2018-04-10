//
//  StringExt.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/10/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
}
