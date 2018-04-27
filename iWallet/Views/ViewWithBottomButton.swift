//
//  ScrollViewWithBottomButton.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/27/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class ViewWithBottomButton: UIView {
    let addButton = UIButton()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let location = CGPoint(x: self.frame.width - 80, y: self.frame.height - 80)
        let sizeTop = CGSize(width: 64, height: 64)
        addButton.frame = CGRect(origin: location, size: sizeTop)
        addButton.setImage(UIImage(named: "AddIcon") , for: .normal)
        self.addSubview(addButton)
    }

}
