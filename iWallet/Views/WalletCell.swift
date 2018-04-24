//
//  WalletCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {
    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var expanceLbl: UILabel!
    @IBOutlet weak var incomeLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String, expance: String, income: String, card: Bool, cardNumber: Int = 0){
        accountNameLbl.text = name
        expanceLbl.text = expance
        incomeLbl.text = income
        if card {
            imgView.image = UIImage(named: "CardIcon" + "\(cardNumber % 2)")
        } else {
            imgView?.image = UIImage(named: "CashIcon")
        }
        selectionStyle = .none
    }
    
}
