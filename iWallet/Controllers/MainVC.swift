//
//  MainVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar

class MainVC: UIViewController {


    @IBOutlet weak var cashTableView: UITableView!
    @IBOutlet weak var cardsTableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var expanceBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    
    var cards = [(name: String, expance: String, income: String)]()
    var cash = [(name: String, expance: String, income: String)]()
    var accounts = [(name: String, expance: String, income: String)]()
    var date = Date()
    private var currentCalendar: Calendar?
    var selectedCardsRow: Int?
    var selectedCashRow: Int?
    @IBAction func openAddTransactionBtnPressed(_ sender: Any) {
        let addTransaction = AddTransactionVC()
        addTransaction.modalPresentationStyle = .custom
        addTransaction.delegate = self
        presentDetail(addTransaction)
    }
    @IBAction func expanceBtnPressed(_ sender: Any) {
    }
    @IBAction func incomeBtnPressed(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cashTableView.delegate = self
        cashTableView.dataSource = self
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        cashTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        cardsTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        setMonthLabel()
        fetchData()
    }
    func fetchData(){
        cash = []
        cards = []
        accounts = []
        CoreDataService.instance.fetchAccountsIncome(ByDate: date) { (accountsArray) in
            for arrayItem in accountsArray {
                    if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double {
                            accounts.append((name: account, expance: "0.0", income: "\(sum.roundTo(places: 2))"))
                    }
            }
            CoreDataService.instance.fetchAccountsExpance(ByDate: date, complition: { (accountsArray) in
                for arrayItem in accountsArray {
                        if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double {
                            var flagExist = false
                                for (index, item) in accounts.enumerated() {
                                    if item.name == account {
                                        let name = item.name
                                        let income = item.income
                                        accounts.remove(at: index)
                                        accounts.append((name: item.name, expance: "\(sum.roundTo(places: 2))", income: item.income))
                                        flagExist = true
                                    }
                                }
                                if !flagExist {
                                    accounts.append((name: account, expance: "\(sum.roundTo(places: 2))", income: "0.0"))
                                }
                        }
                }
                for accountItem in accounts {
                    CoreDataService.instance.fetchAccount(byName: accountItem.name, complition: { (fetchedAccounts) in
                        for fetchedAccount in fetchedAccounts {
                            guard let type = fetchedAccount.type, let currency = fetchedAccount.currency else {continue}
                            if  type == AccountType.Cash.rawValue {
                                cash.append((name: accountItem.name, expance: accountItem.expance, income: accountItem.income  + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)))
                            } else {
                                 cards.append((name: accountItem.name, expance: accountItem.expance , income: accountItem.income + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)))
                            }
                        }
                    })
                }
                cardsTableView.reloadData()
                cashTableView.reloadData()
            })
        }
    }
    func setMonthLabel(){
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: date, calendar: currentCalendar).globalDescription
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        date = date.previousMonth()
        setMonthLabel()
        fetchData()
    }
    
    @IBAction func forwardBtnPressed(_ sender: Any) {
        date = date.nextMonth()
        setMonthLabel()
        fetchData()
    }
    
}

extension MainVC : BriefProtocol{
    func handleTransaction() {
        fetchData()
    }
}


extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cashTableView {
            return  cash.count
        } else {
            return cards.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if tableView == cashTableView {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell{
                    let cash = self.cash[indexPath.row]
                    cell.configureCell(name: cash.name, expance: cash.expance, income: cash.income, selected: selectedCashRow == indexPath.row, card: false)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell{
                    let card = self.cards[indexPath.row]
                    cell.configureCell(name: card.name, expance: card.expance, income: card.income, selected: selectedCardsRow == indexPath.row, card: true, cardNumber: indexPath.row)
                    return cell
                }
            }

        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cashTableView {
            selectedCashRow = indexPath.row
            selectedCardsRow = nil
        } else {
            selectedCashRow = nil
            selectedCardsRow = indexPath.row
        }
        cashTableView.reloadData()
        cardsTableView.reloadData()
    }
    
   
}

