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
    
    var accounts = [Account]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoreDataService.instance.fetchAccounts { (accounts) in
            self.accounts = accounts
        }
        tableView.reloadData()
    }
    @IBAction func addAccountBtnPressed(_ sender: Any) {
        let addAccountVC = AddAccountVC()
        presentDetail(addAccountVC)
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
        AccountHelper.instance.currentAccount = accounts[indexPath.row].objectID.uriRepresentation().absoluteString
        let brief = storyboard?.instantiateViewController(withIdentifier: "BriefByAccountVC")
        revealViewController().pushFrontViewController(brief, animated: true)
    }
    
}
