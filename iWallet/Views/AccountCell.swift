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
    
   func configureCell(account: Account) {
        if String(describing: account.objectID) == AccountHelper.instance.currentAccount  {
              accountNameLbl.font = UIFont(name: "Avenir-Heavy", size: 24)
              accountCurrencyLbl.font = UIFont(name: "Avenir-Heavy", size: 24)
        }
        accountNameLbl.text = account.name
        if let currency = account.currency {
            accountCurrencyLbl.text = AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)
        }
    }
}