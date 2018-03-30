//
//  AddTransactionVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddTransactionVC: UIViewController {

    @IBOutlet weak var operationsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        operationsView.bindToKeyBoard()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func saveTransactionBtnPressed(_ sender: Any) {
        dismissDetail()
    }
}
