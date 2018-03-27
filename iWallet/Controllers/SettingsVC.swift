//
//  SettingsVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/27/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var categoryEditableSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryEditableSwitch.setOn(CategoryHelper.instance.editableCategories, animated: true)
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
    @IBAction func switchStatusChanged(_ sender: Any) {
        CategoryHelper.instance.editableCategories = !CategoryHelper.instance.editableCategories
    }
}
