//
//  ColorCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var colorImg : UIImageView!
    func configure(color: UIColor) {
        colorImg.backgroundColor = color
    }
}


