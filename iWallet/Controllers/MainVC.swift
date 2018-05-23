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
    @IBOutlet weak var costsBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var coinView: ViewWithBottomButton!
    @IBOutlet weak var parentCategoryScrollView: UIScrollView!
    @IBOutlet weak var childCategoryScrollView: UIScrollView!
    
    
    var cards = [(name: String, costs: String, income: String)]()
    var cash = [(name: String, costs: String, income: String)]()
    var accounts = [(name: String, costs: String, income: String, rate: Double)]()
    var date = Date()
    var parentCategories = [CoinCategory]()
    var childCategories = [[CoinCategory]]()
    private var currentCalendar: Calendar?
    var selectedCardsRow: Int?
    var selectedCashRow: Int?
    let baseCategoryHeight = 125.0
    let minbaseCategoryHeight = 100.0
    let minChildCategoryHeight = 80.0
    var parentCategoryHeight = 125.0
    var childCategoryHeight = 100.0

    var parentCategoryCollectionView: UICollectionView?
    var childCategoryCollectionView: UICollectionView?
    let layoutPCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let layoutCCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var selectedParentCategory: Int?

    @IBAction func costsBtnPressed(_ sender: Any) {
        incomeBtn.isEnabled = true
        costsBtn.isEnabled = false
        incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        costsBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        if let cardsRow = selectedCardsRow {
            fetchCategoriesCostsData(account: cards[cardsRow].name)
        }
        if let cashRow = selectedCashRow {
            fetchCategoriesCostsData(account: cash[cashRow].name)
        }
        
    }
    
    @IBAction func incomeBtnPressed(_ sender: Any) {
        incomeBtn.isEnabled = false
        costsBtn.isEnabled = true
        incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        costsBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        if let cardsRow = selectedCardsRow {
            fetchCategoriesIncomeData(account: cards[cardsRow].name)
        }
        if let cashRow = selectedCashRow {
            fetchCategoriesIncomeData(account: cash[cashRow].name)
        }
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
    
    @objc func addTransactionBtnPressed(){
        let addTransaction = AddTransactionVC()
        addTransaction.modalPresentationStyle = .custom
        addTransaction.delegate = self
        presentDetail(addTransaction)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cashTableView.delegate = self
        cashTableView.dataSource = self
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        cashTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        cardsTableView.register(UINib(nibName: "WalletCell", bundle: nil), forCellReuseIdentifier: "WalletCell")
        setCategoryHeight()
        coinView.addButton.addTarget(self, action: #selector(MainVC.addTransactionBtnPressed), for: .touchUpInside)
        layoutPCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutPCV.minimumInteritemSpacing = 8
        layoutPCV.minimumLineSpacing = 8
        
        layoutCCV.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layoutCCV.minimumInteritemSpacing = 8
        layoutCCV.minimumLineSpacing = 8
        
        parentCategoryCollectionView = UICollectionView(frame: CGRect(x: 0.0, y: 0.0, width: Double(self.coinView.frame.width), height: parentCategoryHeight), collectionViewLayout: layoutPCV)
        parentCategoryCollectionView?.delegate = self
        parentCategoryCollectionView?.dataSource = self
        parentCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        parentCategoryCollectionView?.showsVerticalScrollIndicator = false
        parentCategoryCollectionView?.showsHorizontalScrollIndicator = false
        parentCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        childCategoryCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Double(self.coinView.frame.width), height: childCategoryHeight), collectionViewLayout: layoutCCV)
        childCategoryCollectionView?.delegate = self
        childCategoryCollectionView?.dataSource = self
        childCategoryCollectionView?.register(UINib(nibName: "CoinCell", bundle: nil), forCellWithReuseIdentifier: "CoinCell")
        childCategoryCollectionView?.showsVerticalScrollIndicator = false
        childCategoryCollectionView?.showsHorizontalScrollIndicator = false
        childCategoryCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        parentCategoryScrollView?.contentSize = CGSize(width: coinView.frame.width, height: CGFloat(parentCategoryHeight))
        parentCategoryScrollView?.showsVerticalScrollIndicator = false
        parentCategoryScrollView?.showsHorizontalScrollIndicator = false
        parentCategoryScrollView?.delegate = self
        parentCategoryScrollView?.addSubview(parentCategoryCollectionView!)
        

        childCategoryScrollView?.contentSize = CGSize(width: coinView.frame.width, height: CGFloat(childCategoryHeight))
        childCategoryScrollView?.showsVerticalScrollIndicator = false
        childCategoryScrollView?.showsHorizontalScrollIndicator = false
        childCategoryScrollView?.delegate = self
        childCategoryScrollView?.addSubview(childCategoryCollectionView!)
    
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        setMonthLabel()
        fetchData()
        setCategoryContentWidth()
    }
    func setCategoryHeight(){
        if CGFloat(parentCategoryHeight + childCategoryHeight + 8) > coinView.frame.height {
            parentCategoryHeight = minbaseCategoryHeight
            childCategoryHeight = minChildCategoryHeight
        }
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
                widthChild += Double(childCategories[selectedParent].count) * (childCategoryHeight + 8)
                widthChild -= 8
        }
        parentCategoryCollectionView?.frame = CGRect(x: 0, y: 0, width: widthParent < (parentCategoryHeight + 16) ? (parentCategoryHeight + 16) : widthParent, height: parentCategoryHeight)
        childCategoryCollectionView?.frame = CGRect(x: 0, y: 0, width: widthChild < (childCategoryHeight + 16) ? (childCategoryHeight + 16) : widthChild, height: childCategoryHeight)
        parentCategoryScrollView.contentSize = CGSize(width: CGFloat(widthParent), height: CGFloat(parentCategoryHeight))
        childCategoryScrollView.contentSize = CGSize(width: CGFloat(widthChild), height: CGFloat(childCategoryHeight))
    }
    
    func fetchCategoriesCostsData(account: String){
        selectedParentCategory = nil
        parentCategories = []
        childCategories = []
        CoreDataService.instance.fetchCategoriesCosts(ByAccount: account, WithDate: date, complition: { (results) in
            var parentIterator = ""
            var parentSum = 0.0
            var parentIndex = 0
            var parentColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            for arrayItem in results {
                
                if let category = arrayItem["category.name"] as? String, let sum = arrayItem["sum"] as? Double {
                    if let parent = arrayItem["category.parent.name"] as? String {
                        if parent != parentIterator {
                            if parentIterator.isEmpty {
                                CoreDataService.instance.fetchCategoryParent(ByName: parent, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                })
                                childCategories.append([])
                                parentIterator = parent
                            } else {
                                CoreDataService.instance.fetchCategoryParent(ByName: parentIterator, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                    childCategories.append([])
                                    parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
                                    parentIterator = parent
                                    parentIndex += 1
                                    parentSum = 0.0
                                })
                            }
                        }
                        childCategories[parentIndex].append(CoinCategory(name: category, amount: sum, color: parentColor))
                        parentSum += sum
                    } else {
                        if parentIterator.isEmpty {
                            CoreDataService.instance.fetchCategoryParent(ByName: category, complition: { (fetchedParent) in
                                for item in fetchedParent {
                                    parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                }
                            })
                            childCategories.append([])
                            parentIterator = category
                        } else {
                            if category != parentIterator {
                                CoreDataService.instance.fetchCategoryParent(ByName: parentIterator, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                    childCategories.append([])
                                    if !parentIterator.isEmpty{
                                        parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
                                    }
                                    parentIterator = category
                                    parentIndex += 1
                                    parentSum = 0.0
                                })
                            }
                        }
                        parentSum += sum
                    }
                    
                }
            }
            if !parentIterator.isEmpty {
                parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
            }
        })
        if parentCategories.count > 0 {
            selectedParentCategory = 0
        }
        setCategoryContentWidth()
        parentCategories.sort { (arg0, arg1) -> Bool in
            return arg0.amount > arg1.amount
        }
        for (index, item) in childCategories.enumerated() {
            var childArray = item
            childArray.sort { (arg0, arg1) -> Bool in
                return arg0.amount > arg1.amount
            }
            childCategories[index] = childArray
        }
        parentCategoryCollectionView?.reloadData()
        childCategoryCollectionView?.reloadData()
    }
    
    func fetchCategoriesIncomeData(account: String){
        selectedParentCategory = nil
        parentCategories = []
        childCategories = []
        CoreDataService.instance.fetchCategoriesIncome(ByAccount: account, WithDate: date, complition: { (results) in
            var parentIterator = ""
            var parentSum = 0.0
            var parentIndex = 0
            var parentColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            for arrayItem in results {
                
                if let category = arrayItem["category.name"] as? String, let sum = arrayItem["sum"] as? Double {
                    if let parent = arrayItem["category.parent.name"] as? String {
                        if parent != parentIterator {
                            if parentIterator.isEmpty {
                                CoreDataService.instance.fetchCategory(ByName: parent, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                })
                                childCategories.append([])
                                parentIterator = parent
                            } else {
                                CoreDataService.instance.fetchCategory(ByName: parentIterator, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                    childCategories.append([])
                                    parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
                                    parentIterator = parent
                                    parentIndex += 1
                                    parentSum = 0.0
                                })
                            }
                        }
                        childCategories[parentIndex].append(CoinCategory(name: category, amount: sum, color: parentColor))
                        parentSum += sum
                    } else {
                        if parentIterator.isEmpty {
                            CoreDataService.instance.fetchCategory(ByName: category, complition: { (fetchedParent) in
                                for item in fetchedParent {
                                    parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                }
                            })
                            childCategories.append([])
                            parentIterator = category
                        } else {
                            if category != parentIterator {
                                CoreDataService.instance.fetchCategory(ByName: parentIterator, complition: { (fetchedParent) in
                                    for item in fetchedParent {
                                        parentColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                                    }
                                    childCategories.append([])
                                    if !parentIterator.isEmpty{
                                        parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
                                    }
                                    parentIterator = category
                                    parentIndex += 1
                                    parentSum = 0.0
                                })
                            }
                        }
                         parentSum += sum
                    }
                    
                }
            }
            if !parentIterator.isEmpty {
                parentCategories.append(CoinCategory(name: parentIterator, amount: parentSum, color: parentColor))
            }
        })
        if parentCategories.count > 0 {
            selectedParentCategory = 0
        }
        setCategoryContentWidth()
        parentCategories.sort { (arg0, arg1) -> Bool in
            return arg0.amount > arg1.amount
        }
        for (index, item) in childCategories.enumerated() {
            var childArray = item
            childArray.sort { (arg0, arg1) -> Bool in
                return arg0.amount > arg1.amount
            }
            childCategories[index] = childArray
        }
        parentCategoryCollectionView?.reloadData()
        childCategoryCollectionView?.reloadData()
    }

    func fetchCategoryData(ByAccount account: (name: String, costs: String, income: String, rate: Double)){
        let costs = Double(account.costs) ?? 0.0
        let income = Double(account.income) ?? Double(account.income[1..<account.income.count]) ?? 0.0
        if income > costs {
           fetchCategoriesIncomeData(account: account.name)
           incomeBtn.isEnabled = false
            costsBtn.isEnabled = true
            incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
            costsBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
        } else {
           fetchCategoriesCostsData(account: account.name)
            incomeBtn.isEnabled = true
            costsBtn.isEnabled = false
            incomeBtn.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75), for: .normal)
            costsBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        }
    }
    
    func fetchAccountsIncome(complition: @escaping (Bool)->()) {
        CoreDataService.instance.fetchAccountsIncome(WithStartDate: date.startOfMonth(), WithEndDate: date.endOfMonth()){ (accountsArray) in
            if accountsArray.count == 0 {
                complition(false)
            } else {
                for (index, arrayItem) in accountsArray.enumerated() {
                    if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double, let currency = arrayItem["account.currency"] as? String {
                        ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: "USD", complition: { (rate) in
                            self.accounts.append((name: account, costs: "0.0", income: "\(sum.roundTo(places: 2))", rate: rate))
                            if index == accountsArray.count - 1 {
                                complition(true)
                            }
                        })
                    }
                }
            }
        }
    }
    
    func fetchAccountsCosts(complition: @escaping (Bool)->()){
        CoreDataService.instance.fetchAccountsCosts(WithStartDate: self.date.startOfMonth(), WithEndDate: self.date.endOfMonth(), complition: { (accountsArray) in
            if accountsArray.count == 0 {
                complition(false)
            } else {
                for (indexOfFetchedData, arrayItem) in accountsArray.enumerated() {
                    if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double, let currency = arrayItem["account.currency"] as? String {
                        var flagExist = false
                        for (index, item) in accounts.enumerated() {
                            if item.name == account {
                                accounts.remove(at: index)
                                accounts.append((name: item.name, costs: "\(sum.roundTo(places: 2))", income: item.income, rate: item.rate))
                                flagExist = true
                                if indexOfFetchedData == accountsArray.count - 1 {
                                    complition(true)
                                }
                            }
                        }
                        if !flagExist {
                            ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: "USD", complition: { (rate) in
                                self.accounts.append((name: account, costs: "\(sum.roundTo(places: 2))", income: "0.0", rate: rate))
                                if indexOfFetchedData == accountsArray.count - 1 {
                                    complition(true)
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    func fetchData(){
        cash = []
        cards = []
        accounts = []
        selectedCashRow = nil
        selectedCardsRow = nil
        self.fetchAccountsIncome { (succes) in
            self.fetchAccountsCosts(complition: { (success) in
                self.accounts.sort(by: { (arg0, arg1) -> Bool in
                        let (name0, costs0, income0, rate0) = arg0
                        let (name1, costs1, income1, rate1) = arg1
                        let sum0 = (Double(costs0) ?? 0.0) * rate0  + (Double(income0) ?? 0.0) * rate0
                        let sum1 = (Double(costs1) ?? 0.0 ) * rate1 + (Double(income1) ?? 0.0) * rate1

                        return sum0 > sum1
                    })
            
                for (index, accountItem) in self.accounts.enumerated() {
                        CoreDataService.instance.fetchAccount(byName: accountItem.name, complition: { (fetchedAccounts) in
                            for fetchedAccount in fetchedAccounts {
                                guard let type = fetchedAccount.type, let currency = fetchedAccount.currency else {continue}
                                if  type == AccountType.Cash.rawValue {
                                    if index == 0 {
                                        self.selectedCashRow = 0
                                    }
                                    self.cash.append((name: accountItem.name, costs: accountItem.costs, income:  AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency) + accountItem.income))
                                } else {
                                    if index == 0 {
                                        self.selectedCardsRow = 0
                                    }
                                     self.cards.append((name: accountItem.name, costs: accountItem.costs , income:  AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency) + accountItem.income))
                                }
                            }
                        })
                    }
                    if self.accounts.count > 0 {
                        self.fetchCategoryData(ByAccount: self.accounts[0])
                    } else {
                        self.parentCategories = []
                        self.childCategories = []
                        self.selectedParentCategory = nil
                        self.parentCategoryCollectionView?.reloadData()
                        self.childCategoryCollectionView?.reloadData()
                    }
            
                    self.cardsTableView.reloadData()
                    self.cashTableView.reloadData()
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
    func handleTransaction(date: Date) {
        fetchData()
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parentCategoryScrollView {
            scrollView.contentSize.height = CGFloat(parentCategoryHeight)
        } else {
           scrollView.contentSize.height = CGFloat(childCategoryHeight)
        }
        
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
        var newDimension = parentCategoryHeight - Double(index * Int(0.05 * parentCategoryHeight))
        newDimension = newDimension < parentCategoryHeight * 0.8 ? parentCategoryHeight * 0.8 : newDimension
        return Double(newDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            if collectionView == parentCategoryCollectionView {
                if let cell = parentCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    let category = parentCategories[indexPath.row]
                    cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: getDimensionParentCategoryCell(index: indexPath.row) / baseCategoryHeight, parent: true, selected: selectedParentCategory == indexPath.row)
                    return cell
                }
            } else {
                if let cell = childCategoryCollectionView?.dequeueReusableCell(withReuseIdentifier: "CoinCell", for: indexPath) as? CoinCell {
                    if let selectedParent = selectedParentCategory {
                        let category = childCategories[selectedParent][indexPath.row]
                        cell.configureCell(name: category.name, amount: category.amount, color: category.color, currencySymbol: "$",dimensionRate: childCategoryHeight / baseCategoryHeight, parent: false)
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
            setCategoryContentWidth()
            parentCategoryCollectionView?.reloadData()
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
                    cell.configureCell(name: cash.name, costs: cash.costs, income: cash.income, selected: selectedCashRow == indexPath.row, card: false, number: indexPath.row)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as? WalletCell{
                    let card = self.cards[indexPath.row]
                    cell.configureCell(name: card.name, costs: card.costs, income: card.income, selected: selectedCardsRow == indexPath.row, card: true, number: indexPath.row)
                    return cell
                }
            }

        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cashTableView {
            selectedCashRow = indexPath.row
            selectedCardsRow = nil
            fetchCategoryData(ByAccount: (name: cash[indexPath.row].name, costs: cash[indexPath.row].costs, income: cash[indexPath.row].income, rate: 1.0))
        } else {
            selectedCashRow = nil
            selectedCardsRow = indexPath.row
            fetchCategoryData(ByAccount: (name: cards[indexPath.row].name, costs: cards[indexPath.row].costs, income: cards[indexPath.row].income, rate: 1.0))
        }
        cashTableView.reloadData()
        cardsTableView.reloadData()
    }
    
   
}

