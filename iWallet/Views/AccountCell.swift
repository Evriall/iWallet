//
//  AccountCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/28/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var accountCurrencyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(account: Account, colorText: UIColor = #colorLiteral(red: 0.9960784314, green: 0.8274509804, blue: 0.1921568627, alpha: 1)) {
        if account.id == AccountHelper.instance.currentAccount  {
              accountNameLbl.font = UIFont(name: "Avenir-Heavy", size: 24)
              accountCurrencyLbl.font = UIFont(name: "Avenir-Heavy", size: 24)
        } else {
            accountNameLbl.font = UIFont(name: "Avenir-Book", size: 20)
            accountCurrencyLbl.font = UIFont(name: "Avenir-Book", size: 20 )
        }
        accountNameLbl.text = account.name
        accountNameLbl.textColor = colorText
        accountCurrencyLbl.textColor = colorText
        if let currency = account.currency {
            accountCurrencyLbl.text = AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)
        } else {
            accountCurrencyLbl.text = ""
        }
        
        AccountHelper.instance.evaluateBalance(byAccount: account) { (balance) in
            accountCurrencyLbl.text = "\(balance)" + accountCurrencyLbl.text!
        }
    }
}
