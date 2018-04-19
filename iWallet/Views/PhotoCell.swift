//
//  PhotoCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/18/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(image: UIImage){
        photoImageView.image = image
    }
}
