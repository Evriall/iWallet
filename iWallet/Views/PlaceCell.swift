//
//  PlaceCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/20/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(title: String?, subtitle: String?) {
        self.titleLbl.text = title
        if let subtitle = subtitle {
            if subtitle.isEmpty {
               self.subTitleLbl.isHidden = true
            } else {
                self.subTitleLbl.text = subtitle
            }
        } else {
            self.subTitleLbl.isHidden = true
        }
        
        
    }
}
