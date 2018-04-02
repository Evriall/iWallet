//
//  BriefByAccountVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/2/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class BriefByAccountVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    var account: Account?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements(){
        guard let currentAccountObjectID = AccountHelper.instance.currentAccount else {return}
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        tableView.delegate = self
        tableView.dataSource = self
        CoreDataService.instance.fetchAccount(ByObjectID: currentAccountObjectID) { (account) in
            self.account = account
            titleLbl.text = account.name
        }
    }
    @IBAction func addTransactionBtnPressed(_ sender: Any) {
        let addTransaction = AddTransactionVC()
        addTransaction.modalPresentationStyle = .custom
        presentDetail(addTransaction)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
    }
    @IBAction func forwardBtnPressed(_ sender: Any) {
    }
}

extension BriefByAccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
