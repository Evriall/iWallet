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
    @IBOutlet weak var currencyRateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(pairCode: String, currencyRate: String = ""){
        let pairName = Locale.current.localizedString(forCurrencyCode: pairCode) ?? ""
        Lbl.text = pairName
        if !currencyRate.isEmpty {
            currencyRateLbl.text = currencyRate
            currencyRateLbl.isHidden = false
        }
    }
    
    func configureCell(item: String){
        Lbl.text = item
    }

}
