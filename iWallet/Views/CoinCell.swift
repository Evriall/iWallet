//
//  CoinCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/26/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class CoinCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(name: String, amount: Double, color: UIColor, currencySymbol: String, dimensionRate: Double = 1.0, parent: Bool){
        categoryLbl.text = name
        amountLbl.text = "\(amount)"
        currencyLbl.text = currencySymbol
        imgView.image = UIImage(named: parent ? "CoinIconGold" : "CoinIconSilver")
        imgView.backgroundColor = color
        let currencyFontSize = dimensionRate  * 120
        let amountFontSize = dimensionRate  * 20
        let categoryFontSize = dimensionRate  * 17
        currencyLbl.font = UIFont(name: "Avenir-Heavy", size: CGFloat(currencyFontSize))
        amountLbl.font = UIFont(name: "Avenir-Book", size: CGFloat(amountFontSize))
        categoryLbl.font = UIFont(name: "Avenir-Book", size: CGFloat(categoryFontSize))
    }

}
