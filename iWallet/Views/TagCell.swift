//
//  TagCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/15/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 5
    }
    
    func configureCell(title: String){
        titleLbl.text = title
    }

}
