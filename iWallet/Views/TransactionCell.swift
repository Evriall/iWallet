//
//  TransactionCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/3/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(transaction: Transaction){
        categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: transaction.category?.color)
        categoryNameLbl.lineBreakMode = .byWordWrapping
        categoryNameLbl.text = CategoryHelper.instance.textNameCategory(category: transaction.category)
        guard let transactionType = transaction.type else {return}
        amountLbl.text = transactionType == TransactionType.costs.rawValue ? "-" + transaction.amount.description : transaction.amount.description
        var description = ""
        if let transfer = transaction.transfer {
            guard let nameTransactionFrom = transaction.account?.name else {return}
            guard let nameTransactionTo = transfer.account?.name else {return}
            if transactionType == TransactionType.costs.rawValue {
                description = "\(nameTransactionFrom) → \(nameTransactionTo)"
            } else {
                description = "\(nameTransactionTo) → \(nameTransactionFrom)"
            }
        } else if let place = transaction.place {
            description = place.name ?? ""
        }
        infoLbl.text = description
    }
    
    func configureCell(name: String, amount: String, dark: Bool) {
        categoryImg.isHidden = true
        categoryNameLbl.text = name
        amountLbl.text = amount
        infoLbl.isHidden = true
        if dark {
            self.backgroundColor = #colorLiteral(red: 0, green: 0.8549019608, blue: 0.8745098039, alpha: 1)
        } else {
            self.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        }
    }

}
