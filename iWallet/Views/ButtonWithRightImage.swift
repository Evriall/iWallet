//
//  ButtonWithImage.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class ButtonWithRightImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (bounds.width - bounds.height), bottom: 0, right: 0)
//         titleEdgeInsets = UIEdgeInsets(top: 0, left: -1.5 * (imageView?.frame.width)!, bottom: 0, right: (imageView?.frame.width)!)
              titleEdgeInsets = UIEdgeInsets(top: 0, left: -1 * (imageView?.frame.width)!, bottom: 0, right: (imageView?.frame.width)!)
            contentHorizontalAlignment = .left
        }
    }
}
