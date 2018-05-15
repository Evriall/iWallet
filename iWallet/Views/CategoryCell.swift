//
//  CategoryCell.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/26/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var openChildrenCategoriesBtn: UIButton!
    @IBOutlet weak var closeChildrenCategoriesBtn: UIButton!
    @IBOutlet weak var imgLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var CtgNameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var openCategoryForEditingBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(category: Category, showChildren: Bool = true, editable: Bool = false) {
        openCategoryForEditingBtn.isHidden = !editable
        let bgColor = EncodeDecodeService.instance.returnUIColor(components: category.color)
        categoryImg.backgroundColor = bgColor
        categoryNameLbl.text = category.name
        CtgNameLeadingConstraint.constant = 8
        selectionStyle = .none
        if category.parent != nil {
            CtgNameLeadingConstraint.constant = 24
            self.openChildrenCategoriesBtn.isHidden = true
            self.closeChildrenCategoriesBtn.isHidden = true
        } else if showChildren {
            CoreDataService.instance.fetchCategoryChildrenByParent(category) { (children) in
                if children.count > 0 {
                    guard let name = category.name else {return}
                    var childrenShown = CategoryHelper.instance.check(categoryName: name)
                    self.openChildrenCategoriesBtn.isHidden = childrenShown
                    self.closeChildrenCategoriesBtn.isHidden = !childrenShown
                } else {
                    self.openChildrenCategoriesBtn.isHidden = true
                    self.closeChildrenCategoriesBtn.isHidden = true
                }
            }
        }
       
    }
    @IBAction func openChildrenCategoriesBtnPressed(_ sender: Any) {
    }
    @IBAction func closeChildrenCategoriesBtnPressed(_ sender: Any) {
    }
}
