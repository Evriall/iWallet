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
    @IBOutlet weak var costsLbl: UILabel!
    @IBOutlet weak var incomeLbl: UILabel!
    @IBOutlet weak var imgViewTop: UIImageView!
    @IBOutlet weak var imgViewBottom: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String, costs: String, income: String, selected: Bool, card: Bool, cardNumber: Int = 0){
        accountNameLbl.text = name
        costsLbl.text = costs
        incomeLbl.text = income
        if card {
            imgViewTop.image = UIImage(named: "CardIconTop" + "\(cardNumber % 2)")
            imgViewBottom.image = UIImage(named: "CardIconBottom" + "\(cardNumber % 2)")
        } else {
            imgViewTop?.image = UIImage(named: "CashIconTop")
            imgViewBottom?.image = UIImage(named: "CashIconBottom")
        }
        imgViewBottom.isHidden = !selected
        selectionStyle = .none
    }

    
}
