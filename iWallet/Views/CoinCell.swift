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
    @IBOutlet weak var categoryLbl: CircularLabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var amountLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountTrailingConstraint: NSLayoutConstraint!
    
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
        amountLeadingConstraint.constant *= CGFloat(dimensionRate)
        amountTrailingConstraint.constant *= CGFloat(dimensionRate)
        let currencyFontSize = dimensionRate  * 80
        let amountFontSize = dimensionRate  * 20 < 12.0 ? 12.0 : dimensionRate  * 20
        let categoryFontSize = dimensionRate  * 17 < 10.0 ? 10.0 : dimensionRate  * 17
        currencyLbl.font = UIFont(name: "Avenir-Heavy", size: CGFloat(currencyFontSize))
        amountLbl.font = UIFont(name: "Avenir-Heavy", size: CGFloat(amountFontSize))
        amountLbl.textColor = parent ? #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 0.7) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
        currencyLbl.textColor = parent ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2) :  #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 0.2) 
        categoryLbl.textColor = parent ? #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 0.7) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7)
        categoryLbl.font = UIFont(name: "Avenir-Book", size: CGFloat(categoryFontSize))
    }

}
