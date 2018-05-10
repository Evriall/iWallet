//
//  PlaceDetailsVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/9/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import MapKit
import CVCalendar

class PlaceDetailsVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLbl: UILabel!
    
    var mapPlace: MapPlace?
    var mapVC: MapVC?
    var date = Date()
    var details = [Detail]()
    var accounts = [AccountDetail]()
    var dates = [[DateDetail]]()
    var transactions = [[TransactionDetail]]()
    private var currentCalendar: Calendar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let mapPlace = mapPlace {
            titleLbl.text = mapPlace.place
        }
        self.tableView.separatorColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionIndexColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        self.tableView.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        self.tableView.tableFooterView = UIView()
        if let latitude = mapPlace?.latitude, let longitude = mapPlace?.longitude{
            fetchTransactions( latitude: latitude, longitude: longitude, date: self.date)
        }
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
        setMonthLabel()
    }
    
    func setMonthLabel(){
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: date, calendar: currentCalendar).globalDescription
        }
    }
    
    func fetchTransactions(latitude: Double, longitude: Double, date: Date){
        accounts = []
        dates = []
        transactions = []
        CoreDataService.instance.fetchTransactions(latitude: latitude, longitude: longitude, date: date){ (transactions) in
            var currentCurrencySymbol = ""
            var currentAccount = ""
            var currentDate = ""
            var balanceByAccount = 0.0
            var balanceByDate = 0.0
            for item in transactions {
                guard let accountName = item.account?.name, let accountCurrency = item.account?.currency else {continue}
                guard let date = item.date?.formatDateToStr() else {continue}
                
                if accountName != currentAccount {
                    if !currentAccount.isEmpty {
                        dates[accounts.count].append(DateDetail(name: currentDate, amount: balanceByDate))
                        accounts.append(AccountDetail(name: currentAccount, amount: balanceByAccount, currencySymbol: currentCurrencySymbol))
                        currentDate = ""
                    }
                    dates.append([])
                    balanceByAccount = 0.0
                    currentAccount = accountName
                    currentCurrencySymbol = AccountHelper.instance.getCurrencySymbol(byCurrencyCode: accountCurrency)
                    
                }
                
                if date != currentDate {
                    if !currentDate.isEmpty {
                        dates[accounts.count].append(DateDetail(name: currentDate, amount: balanceByDate))
                    }
                    balanceByDate = 0.0
                    currentDate = date
                    self.transactions.append([])
                }
                
                balanceByDate += item.type == TransactionType.income.rawValue ? item.amount : (-item.amount)
                balanceByAccount += item.type == TransactionType.income.rawValue ? item.amount : (-item.amount)
                self.transactions[self.transactions.count - 1].append(TransactionDetail(transaction: item))
            }
            if transactions.count > 0 {
                dates[accounts.count].append(DateDetail(name: currentDate, amount: balanceByDate))
            }
            if dates.count > 0 {
                accounts.append(AccountDetail(name: currentAccount, amount: balanceByAccount, currencySymbol: currentCurrencySymbol))
            }
            details = accounts
            self.tableView.reloadData()
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetailFaid()
    }
    
    func findAccountPosition(account: AccountDetail) -> Int{
        for (index,item) in accounts.enumerated() {
            if item === account {
                return index
            }
        }
        return 0
    }
    
    func findDatePosition(date: DateDetail) -> Int{
        var index = 0
        for dateArray in dates {
            for item in dateArray {
                if item === date {
                    return index
                }
                index += 1
            }
        }
        return 0
    }
}

extension PlaceDetailsVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let detail = details[indexPath.row] as? AccountDetail {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(name: detail.name, amount: "\(detail.amount.roundTo(places: 2))\(detail.currencySymbol)", dark: true)
                    return cell
                }
            }
            if let detail = details[indexPath.row] as? DateDetail {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(name: detail.name, amount: "\(detail.amount)", dark: false)
                    return cell
                }
            }
            
            if let detail = details[indexPath.row] as? TransactionDetail{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(transaction: detail.transaction)
                    return cell
                }
            }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let detail  = details[indexPath.row] as? TransactionDetail {
                let addTransaction = AddTransactionVC()
                addTransaction.delegate = mapVC as? BriefProtocol
                addTransaction.transaction = detail.transaction
                addTransaction.modalPresentationStyle = .custom
                presentDetail(addTransaction)
                
            }
            if details[indexPath.row] is AccountDetail {
                if let detail  = details[indexPath.row] as? AccountDetail {
                    if indexPath.row + 1 < details.count {
                        if details[indexPath.row + 1] is AccountDetail {
                            details.insert(contentsOf: dates[findAccountPosition(account: detail)], at: indexPath.row + 1)
                        } else {
                            for _ in (indexPath.row + 1)...(details.count - 1) {
                                if details[indexPath.row + 1] is AccountDetail {
                                    break
                                } else {
                                    details.remove(at: indexPath.row + 1)
                                }
                            }
                        }
                    } else {
                        details.append(contentsOf: dates[findAccountPosition(account: detail)])
                    }
                }
            }
            if details[indexPath.row] is DateDetail {
                if let detail  = details[indexPath.row] as? DateDetail {
                    if indexPath.row + 1 < details.count {
                        if details[indexPath.row + 1] is AccountDetail || details[indexPath.row + 1] is DateDetail{
                            details.insert(contentsOf: transactions[findDatePosition(date: detail)], at: indexPath.row + 1)
                        } else {
                            for _ in (indexPath.row + 1)...(details.count - 1) {
                                if details[indexPath.row + 1] is AccountDetail || details[indexPath.row + 1] is DateDetail{
                                    break
                                } else {
                                    details.remove(at: indexPath.row + 1)
                                }
                            }
                        }
                    } else {
                        details.append(contentsOf: transactions[findDatePosition(date: detail)])
                    }
                }
            }
            tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if details[indexPath.row] is AccountDetail || details[indexPath.row] is DateDetail {
            return 36.0
        } else {
            if let detail = details[indexPath.row] as? TransactionDetail {
                if TransactionHelper.instance.getTransactionDescription(transaction: detail.transaction).isEmpty  && detail.transaction.category?.parent == nil {
                    return 36.0
                } else if TransactionHelper.instance.getTransactionDescription(transaction: detail.transaction).isEmpty  || detail.transaction.category?.parent == nil{
                    return 50.0
                } else {
                    return 74.0
                }
            }
        }
        return 36.0
    }
}
