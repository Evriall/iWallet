//
//  TypeAndCurrencyCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class TypeAndCurrencyCell: UITableViewCell {

    @IBOutlet weak var Lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(item: String){
        Lbl.text = item
    }

}
