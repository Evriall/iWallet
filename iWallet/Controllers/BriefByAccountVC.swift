//
//  BriefByAccountVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/2/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar

class BriefByAccountVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var monthLbl: UILabel!
    var account: Account?
    var date = Date()
    private var currentCalendar: Calendar?
    var sections = [String]()
    var transactions = [[Transaction]]()
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTransactions()
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
        setMonthLabel()
        fetchTransactions()
    }
    
    func setMonthLabel(){
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: date, calendar: currentCalendar).globalDescription
        }
    }
    
    @IBAction func addTransactionBtnPressed(_ sender: Any) {
        let addTransaction = AddTransactionVC()
        addTransaction.delegate = self
        addTransaction.modalPresentationStyle = .custom
        presentDetail(addTransaction)

    }
    @IBAction func backBtnPressed(_ sender: Any) {
        date = date.previousMonth()
        setMonthLabel()
        fetchTransactions()
    }
    @IBAction func forwardBtnPressed(_ sender: Any) {
        date = date.nextMonth()
        setMonthLabel()
        fetchTransactions()
    }
    
    func fetchTransactions(){
        sections = []
        transactions = []
        guard let account = account else {return}
        CoreDataService.instance.fetchTransactions(account: account, date: date) { (transactionsFetched) in
            var sumByDay = 0.0
            var tempDate = ""
            var transactionsByDay = [Transaction]()
            for item in transactionsFetched {
                guard let transactionType = item.type else {continue}
                guard let transactionDate = item.date?.formatDateToStr() else {continue}
                if transactionDate != tempDate {
                    if transactionsByDay.count > 0 {
                        transactions.append(transactionsByDay)
                        sections.append("\(tempDate) \(sumByDay)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: account.currency!))")
                        sumByDay = 0
                        transactionsByDay = []
                    }
                    tempDate = transactionDate
                }
                transactionsByDay.append(item)
                sumByDay += transactionType == TransactionType.expance.rawValue ? -item.amount : item.amount
            }
            if transactionsByDay.count > 0 {
                sections.append("\(tempDate) \(sumByDay)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: account.currency!))")
                transactions.append(transactionsByDay)
            }
        }
        tableView.reloadData()
    }
}

extension BriefByAccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
            cell.configureCell(transaction: transactions[indexPath.section][indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}

extension BriefByAccountVC: BriefProtocol {
    func handleTransaction() {
        fetchTransactions()
    }
}
