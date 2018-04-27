//
//  MainVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar

struct CoinCategory {
    var name = ""
    var amount = 0.0
    var color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
}
class MainVC: UIViewController {


    @IBOutlet weak var cashTableView: UITableView!
    @IBOutlet weak var cardsTableView: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var expanceBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    
    @IBOutlet weak var parentCategoryScrollView: UIScrollView!

    
    var cards = [(name: String, expance: String, income: String)]()
    var cash = [(name: String, expance: String, income: String)]()
    var accounts = [(name: String, expance: String, income: String)]()
    var date = Date()
    var parentCategories = [CoinCategory]()
    var childCategories = [[CoinCategory]]()
    private var currentCalendar: Calendar?
    var selectedCardsRow: Int?
    var selectedCashRow: Int?
    var parentCategoryHeight = 150.0
    var childCategoryHeight = 100.0
    var parentCategoryCollectionView: UICollectionView?
    var childCategoryCollectionView: UICollectionView?
    let layoutPCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let layoutCCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var selectedParentCategory: Int?
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
        
        layoutPCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutPCV.minimumInteritemSpacing = 8
        layoutPCV.minimumLineSpacing = 8
        
        layoutCCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutCCV.minimumInteritemSpacing = 8
        layoutCCV.minimumLineSpacing = 8
        
        parentCategoryCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.view.frame.width), height: parentCategoryHeight), collectionViewLayout: layoutPCV)
        parentCategoryCollectionView?.delegate = self
        parentCategoryCollectionView?.dataSource = self
        parentCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        parentCategoryCollectionView?.showsVerticalScrollIndicator = false
        parentCategoryCollectionView?.showsHorizontalScrollIndicator = false
        parentCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        childCategoryCollectionView = UICollectionView(frame: CGRect(x: (parentCategoryHeight - childCategoryHeight) / 2, y: parentCategoryHeight, width: Double(self.view.frame.width), height: childCategoryHeight), collectionViewLayout: layoutCCV)
        childCategoryCollectionView?.delegate = self
        childCategoryCollectionView?.dataSource = self
        childCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        childCategoryCollectionView?.showsVerticalScrollIndicator = false
        childCategoryCollectionView?.showsHorizontalScrollIndicator = false
        childCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        parentCategoryScrollView.delegate = self
        parentCategoryScrollView.addSubview(parentCategoryCollectionView!)
        parentCategoryScrollView.addSubview(childCategoryCollectionView!)
        parentCategoryScrollView.showsVerticalScrollIndicator = false
        parentCategoryScrollView.showsHorizontalScrollIndicator = false
        
        
        parentCategories.append(CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
        parentCategories.append(CoinCategory(name: "Communication", amount: 1000.0, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
        parentCategories.append(CoinCategory(name: "Transport", amount: 100.0, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)))
        parentCategories.append(CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
        parentCategories.append(CoinCategory(name: "Communication", amount: 1000.0, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)))
        parentCategories.append(CoinCategory(name: "Transport", amount: 100.0, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)))
        childCategories.append([CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),CoinCategory(name: "Bank", amount: 10000.0, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))])
        childCategories.append([CoinCategory(name: "Communication", amount: 1000.0, color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))])
        childCategories.append([CoinCategory(name: "Transport", amount: 100.0, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))])
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        setMonthLabel()
        fetchData()
        selectedParentCategory = 0
        setCategoryContentWidth()
    }
    
    func setCategoryContentWidth(){
        var widthParent = 16.0
        var widthChild = 16.0
        var index = 0
        for _ in parentCategories {
            widthParent += getDimensionParentCategoryCell(index: index) + 8
            index += 1
        }
        widthParent -= 8
        if let selectedParent = selectedParentCategory {
            for _ in childCategories[selectedParent] {
                widthChild += childCategoryHeight + 8
            }
        }
        widthChild -= 8
        parentCategoryCollectionView?.frame = CGRect(x: 0, y: 0, width: widthParent, height: widthParent)
        childCategoryCollectionView?.frame = CGRect(x: (parentCategoryHeight - childCategoryHeight) / 2, y:parentCategoryHeight, width: widthChild, height: widthChild)
        parentCategoryScrollView.contentSize = CGSize(width: widthParent > widthChild ? widthParent : widthChild, height: parentCategoryHeight + childCategoryHeight)
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

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        parentCategoryScrollView.contentSize.height = CGFloat(parentCategoryHeight + childCategoryHeight)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == parentCategoryCollectionView{
            return parentCategories.count
        } else {
            if let selectedParent = selectedParentCategory {
                return childCategories[selectedParent].count
            } else {
                return 0
            }
        }
    }
    
    func getDimensionParentCategoryCell(index: Int) -> Double{
        var newDimension = parentCategoryHeight - Double(index * Int(0.15 * parentCategoryHeight))
        newDimension = newDimension < parentCategoryHeight * 0.7 ? parentCategoryHeight * 0.7 : newDimension
        return Double(newDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            if collectionView == parentCategoryCollectionView {
                if let cell = parentCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    let category = parentCategories[indexPath.row]
                    cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: getDimensionParentCategoryCell(index: indexPath.row) / parentCategoryHeight, parent: true)
                    return cell
                }
            } else {
                if let cell = childCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    if let selectedParent = selectedParentCategory {
                        let category = childCategories[selectedParent][indexPath.row]
                        cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: childCategoryHeight / parentCategoryHeight, parent: false)
                        return cell
                    }
                }
            }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == parentCategoryCollectionView {
            return CGSize(width: getDimensionParentCategoryCell(index: indexPath.row), height: getDimensionParentCategoryCell(index: indexPath.row))
        } else {
            return CGSize(width: childCategoryHeight, height: childCategoryHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == parentCategoryCollectionView {
            selectedParentCategory = indexPath.row
            childCategoryCollectionView?.reloadData()
        }
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

