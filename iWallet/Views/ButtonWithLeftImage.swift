//
//  ButtonWithLeftImage.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
@IBDesignable
class ButtonWithLeftImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            let imageWidth:CGFloat = 30.0
            let textWidth = self.titleLabel?.intrinsicContentSize.width
            let buttonWidth = bounds.width
            
            let padding:CGFloat = 30.0
            let rightInset = buttonWidth - imageWidth  - textWidth! - padding
            
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
        }
    }
}
