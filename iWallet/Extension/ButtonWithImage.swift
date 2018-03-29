//
//  ButtonWithImage.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class ButtonWithImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - bounds.height), bottom: 0, right: 0)
         titleEdgeInsets = UIEdgeInsets(top: 0, left: -(bounds.width / 2) + (imageView?.frame.width)!, bottom: 0, right: (imageView?.frame.width)!)

            contentHorizontalAlignment = .center
            layer.borderColor = #colorLiteral(red: 0, green: 0.5803921569, blue: 0.5882352941, alpha: 1)
            layer.borderWidth = 1
            layer.cornerRadius = 5
        }
    }
}
