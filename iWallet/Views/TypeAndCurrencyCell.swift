//
//  TypeAndCurrencyCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class TypeAndCurrencyCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(pairCode: String, currencyRate: String = ""){
        let pairName = Locale.current.localizedString(forCurrencyCode: pairCode) ?? ""
        titleLbl.text = pairName
        if !currencyRate.isEmpty {
            descriptionLbl.text = currencyRate
            descriptionLbl.isHidden = false
        }
//        let bgView = UIView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height))
//        bgView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        self.selectedBackgroundView = bgView
    }
    
    func configureCell(item: String){
        titleLbl.text = item
    }
}
