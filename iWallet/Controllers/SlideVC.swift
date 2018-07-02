//
//  SlideVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SlideVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var accounts = [Account]()
    
    @IBAction func openTagBtnPresed(_ sender: Any) {
        let tagVC = storyboard?.instantiateViewController(withIdentifier: "TagVC")
        revealViewController().pushFrontViewController(tagVC, animated: true)
    }
    @IBAction func openMainBtnPressed(_ sender: Any) {
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainVC")
        revealViewController().pushFrontViewController(mainVC, animated: true)
    }
    
    @IBAction func openReportBtnPressed(_ sender: Any) {
        let reportVC = storyboard?.instantiateViewController(withIdentifier: "ReportVC")
        revealViewController().pushFrontViewController(reportVC, animated: true)
    }
    
    @IBAction func openCategoryBtnPressed(_ sender: Any) {
        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsVC")
        revealViewController().pushFrontViewController(settingsVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AccountCell", bundle: nil), forCellReuseIdentifier: "AccountCell")
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchUser(ByObjectID: currentUser) { (user) in
            usernameLbl.text = user?.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let currentUser = LoginHelper.instance.currentUser else {
            self.accounts = []
            return
        }
        CoreDataService.instance.fetchAccounts(userID: currentUser) { (accounts) in
            self.accounts = accounts
        }
        tableView.reloadData()
    }
    @IBAction func addAccountBtnPressed(_ sender: Any) {
        let addAccountVC = AddAccountVC()
        presentDetail(addAccountVC)
    }
    @IBAction func mapBtnPressed(_ sender: Any) {
        let mapVC = storyboard?.instantiateViewController(withIdentifier: "MapVC")
        revealViewController().pushFrontViewController(mapVC, animated: true)
    }
    
    
    @IBAction func LogoutBtnPressed(_ sender: Any) {
        LoginHelper.instance.currentUser = nil
        let loginVC = LoginVC()
        loginVC.modalPresentationStyle = .custom
        presentSecondaryDetail(presentedViewController: self, viewControllerToPresent: loginVC)
        
    }
    func disableTransactions(ByAccount account: Account, complition: ()->()) {
        CoreDataService.instance.fetchTransactions(ByAccount: account) { (transactions) in
            if transactions.count == 0 {
              complition()
            } else {
                for (index, item) in transactions.enumerated() {
                    item.disabled = true
                    item.lastUpdate = Date()
                    CoreDataService.instance.update(complition: { (success) in
                        if index == transactions.count - 1 {
                            complition()
                        }
                    })
                }
            }
        }
    }
}

extension SlideVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountCell {
            cell.configureCell(account: accounts[indexPath.row])
            return cell
        }
        return AccountCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AccountHelper.instance.currentAccount = accounts[indexPath.row].id
        let brief = storyboard?.instantiateViewController(withIdentifier: "BriefByAccountVC")
        revealViewController().pushFrontViewController(brief, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            let account = self.accounts[indexPath.row]
            account.disabled = true
            account.lastUpdate = Date()
            CoreDataService.instance.update(complition: { (success) in
                if(!success) {
                    debugPrint("Can`t update account")
                }
                else {
                    self.disableTransactions(ByAccount: account, complition: {
                        if let currentAccount = AccountHelper.instance.currentAccount {
                            if currentAccount == account.id {
                                if self.accounts.count > 1 {
                                    if indexPath.row == 0 {
                                        AccountHelper.instance.currentAccount = self.accounts[1].id
                                    } else {
                                         AccountHelper.instance.currentAccount = self.accounts[0].id
                                    }
                                } else {
                                     AccountHelper.instance.currentAccount = nil
                                }
                            } 
                        }
                        self.accounts.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        NotificationCenter.default.post(name: .update, object: nil)
                    })
                }
                
            })
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [deleteAction]
    }
    
}
