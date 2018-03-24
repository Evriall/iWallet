//
//  CategoryCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(category: Category) {
        categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: category.color)
        categoryNameLbl.text = category.name
    }

}
