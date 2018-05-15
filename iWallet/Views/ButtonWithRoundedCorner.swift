//
//  ButtonWithRoundedCorner.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/15/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class ButtonWithRoundedCorner: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

}
