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
    var sections = [(date: String, sum: String)]()
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
        tableView?.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        self.tableView.sectionHeaderHeight = 32
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
                        sections.append(("\(tempDate)", "\(sumByDay)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: account.currency!))"))
                        sumByDay = 0
                        transactionsByDay = []
                    }
                    tempDate = transactionDate
                }
                transactionsByDay.append(item)
                sumByDay += transactionType == TransactionType.costs.rawValue ? -item.amount : item.amount
            }
            if transactionsByDay.count > 0 {
                sections.append(("\(tempDate)", "\(sumByDay)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: account.currency!))"))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let transactionVC = AddTransactionVC()
        transactionVC.transaction = transactions[indexPath.section][indexPath.row]
        presentDetail(transactionVC)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
        headerView.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        let dateLabel = UILabel(frame: CGRect(x: 24, y: 0, width: 64, height: 32))
        dateLabel.text = sections[section].date
        dateLabel.font = UIFont(name: "Avenir-Heavy", size: 17)
        dateLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        let sumLabel = UILabel(frame: CGRect(x: tableView.frame.size.width - 200, y: 0, width: 192, height: 32))
        sumLabel.text = sections[section].sum
        sumLabel.font = UIFont(name: "Avenir-Heavy", size: 17)
        sumLabel.textAlignment = .right
        sumLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        headerView.addSubview(sumLabel)
        headerView.addSubview(dateLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            CoreDataService.instance.fetchTags(transaction: self.transactions[indexPath.section][indexPath.row], complition: { (tags) in
                for item in tags {
                    CoreDataService.instance.removeTag(tag: item)
                }
                CoreDataService.instance.removeTransaction(transaction: self.transactions[indexPath.section][indexPath.row])
            })
            
            self.fetchTransactions()
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [deleteAction]
    }
    
}

extension BriefByAccountVC: BriefProtocol {
    func handleTransaction(date: Date) {
        fetchTransactions()
    }
}
