//
//  SelectAccountVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/5/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

enum TransactionDirection{
    case to
    case from
}

class SelectAccountVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fragmentViewHeightConstraint: NSLayoutConstraint!
    var hidenAccounts = [Account]()
    var accounts = [Account]()
    var delegate: TransactionProtocol?
    var transactionDirection: TransactionDirection?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AccountCell", bundle: nil), forCellReuseIdentifier: "AccountCell")
        guard  let direction = transactionDirection, let currentUser = LoginHelper.instance.currentUser else { return }
        CoreDataService.instance.fetchAccounts(withoutExternal: direction == TransactionDirection.from, userID: currentUser , complition: { (accounts) in
            for item in accounts {
                if !hidenAccounts.contains(item) {
                    self.accounts.append(item)
                }
            }
            let tableDataHeight =  CGFloat(self.accounts.count * 60)
            fragmentViewHeightConstraint.constant = tableDataHeight >= self.view.frame.size.height ? self.view.frame.size.height - 60 : tableDataHeight
        })
    }
}

extension SelectAccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountCell {
            cell.configureCell(account: accounts[indexPath.row], colorText: #colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1))
            return cell
        }
        return AccountCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let direction = self.transactionDirection else {return}
        switch direction {
        case .to:
            delegate?.handleAccountTo(accounts[indexPath.row])
        case .from:
            delegate?.handleAccountFrom(accounts[indexPath.row])
        }
        dismissDetail()
    }
}
