//
//  MainVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var menuBtn: UIButton!
    @IBAction func openAddTransactionBtnPressed(_ sender: Any) {
        let addTransaction = AddTransactionVC()
        addTransaction.modalPresentationStyle = .custom
        presentDetail(addTransaction)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        checkInitData()
    }
    
    func checkInitData(){
        CoreDataService.instance.fetchParents { (categories) in
            if categories.count == 0 {
                CategoryHelper.instance.initCategories()
            }
        }
        CoreDataService.instance.fetchAccounts { (accounts) in
            if accounts.count == 0 {
                AccountHelper.instance.initAccount({ (success) in
                    if success {
                        CoreDataService.instance.fetchAccounts(complition: { (accounts) in
                            for item in accounts {
                                AccountHelper.instance.currentAccount = String(describing: item.objectID)
                            }
                        })
                    }
                })
            }
            
        }
    }
}

