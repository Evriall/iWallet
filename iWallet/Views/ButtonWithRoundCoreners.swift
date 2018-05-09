//
//  ButtonWithRoundCoreners.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/9/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class ButtonWithRoundCoreners: UIButton {
        override func layoutSubviews() {
            super.layoutSubviews()
            self.layer.cornerRadius = 15
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            self.layer.borderWidth = 1
            self.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.clipsToBounds = true
        }
}
