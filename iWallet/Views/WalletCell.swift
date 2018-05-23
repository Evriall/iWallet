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
    
    func configureCell(name: String, costs: String, income: String, selected: Bool, card: Bool, number: Int = 0){
        accountNameLbl.text = name
        costsLbl.text = costs
        incomeLbl.text = income
        if card {
            imgViewTop.image = UIImage(named: "CardIconTop" + "\(number % 3)")
            imgViewBottom.image = UIImage(named: "CardIconBottom" + "\(number % 3)")
            accountNameLbl.textColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            costsLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            incomeLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            imgViewTop?.image = UIImage(named: "CashIconTop" + "\(number % 3)")
            imgViewBottom?.image = UIImage(named: "CashIconBottom" + "\(number % 3)")
            accountNameLbl.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            costsLbl.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            incomeLbl.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
        imgViewBottom.isHidden = !selected
        selectionStyle = .none
    }

    
}
