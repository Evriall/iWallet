//
//  AddTransactionVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import Expression

class AddTransactionVC: UIViewController {

    @IBOutlet weak var amountTxt: UITextField!
    
    @IBOutlet weak var accountsStackView: UIStackView!
    @IBOutlet weak var descriptionTxt: UITextField!
    @IBOutlet weak var typeBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryImg: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var yesterdayBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var otherDateBtn: UIButton!
    @IBOutlet weak var accountFromBtn: ButtonWithLeftImage!
    @IBOutlet weak var accountToBtn: ButtonWithLeftImage!
    @IBOutlet weak var expressionLbl: UILabel!
    @IBOutlet weak var currencyRateLbl: UILabel!
    var currencyBtn: UIButton?
    var tagsCollectionView: UICollectionView?
    var tagTxt =  UITextField()
    let tagImageView = UIImageView(image: UIImage(named: "TagIcon"))
    let layoutCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var transaction: Transaction?
    let height: CGFloat = 40.0
    var category: Category?
    var date = Date()
    var tags = [(name: String, selected: Bool)]()
    var photos = [String: UIImage]()
    var latitude = ""
    var longitude = ""
    var place = ""
    var accountFrom: Account?
    var accountTo: Account?
    var accountsCount = 0
    var currencyForExchange = ""
    var currencyRateForExchange = 1.0

    var amountForAccountCurrency = 0.0
    var delegate: BriefProtocol?
    var amount: Double {
        get{
            let value = amountTxt.text ?? ""
            return Double(value) ?? 0.0
        }
        set{
            amountTxt.text = "\(newValue.roundTo(places: 2))"
        }
    }
    
    var expressionStr: String {
        get{
            return expressionLbl.text ?? ""
        }
        set{
            expressionLbl.text = newValue
            if newValue.isEmpty {
                expressionLbl.isHidden = true
                self.amount = 0.0
            } else {
                expressionLbl.isHidden = false
                if newValue.hasSuffix(Constants.dotSymbol) {return}
                do{
                    let expression = Expression(newValue)
                    let result = try expression.evaluate()
                    self.amount = result
                }catch {
                    return
                }
                
            }
            
            self.amountForAccountCurrency = (self.amount * self.currencyRateForExchange)
            self.amountForAccountCurrency = self.amountForAccountCurrency.roundTo(places: 2)
            guard let currencyAccount = self.accountFrom?.currency else {return}
            currencyRateLbl.text = createDescriptionForCurrencyRate(baseCurrencyCode: self.currencyForExchange, pairCurrencyCode: currencyAccount, rate: currencyRateForExchange, amount: self.amountForAccountCurrency)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
    }
    

    @objc func selectCurrency(){
        guard let currencyCode = accountFrom?.currency else {return}
        let selectCurrency = SelectCurrencyVC()
        selectCurrency.modalPresentationStyle = .custom
        selectCurrency.pairCurrency = currencyCode
        selectCurrency.delegate = self
        presentDetail(selectCurrency)
    }
    
    func setUpUIElements(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddTransactionVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        amountTxt.addTarget(self, action: #selector(AddTransactionVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        
        
        amountTxt.delegate = self
        descriptionTxt.delegate = self
        let opView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height))
        opView.backgroundColor =  #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.8470588235, alpha: 0.5)
        opView.translatesAutoresizingMaskIntoConstraints = false
        
        let openParentheseBtn = UIButton(frame: CGRect(x: 0, y: 0, width: opView.frame.width / 6, height: height))
        openParentheseBtn.setTitle("(", for: .normal)
        openParentheseBtn.setTitleColor(#colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), for: .normal)
        openParentheseBtn.addTarget(self, action: #selector(AddTransactionVC.addOpenParenthese), for: .touchUpInside)
        openParentheseBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)

        let closeParentheseBtn = UIButton(frame: CGRect(x: opView.frame.width / 6, y: 0, width: opView.frame.width / 6, height: height))
        closeParentheseBtn.setTitle(")", for: .normal)
        closeParentheseBtn.setTitleColor(#colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), for: .normal)
        closeParentheseBtn.addTarget(self, action: #selector(AddTransactionVC.addCloseParenthese), for: .touchUpInside)
        closeParentheseBtn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
     
        let addBtn = UIButton(frame: CGRect(x: (opView.frame.width / 6) * 2, y: 0, width: opView.frame.width / 6, height: height))
        addBtn.setImage(UIImage(named: "plusicon"), for: .normal)
        addBtn.addTarget(self, action: #selector(AddTransactionVC.addPlusSymbol), for: .touchUpInside)

        let subBtn = UIButton(frame: CGRect(x: (opView.frame.width / 6) * 3, y: 0, width: opView.frame.width / 6, height: height))
        subBtn.setImage(UIImage(named: "subicon"), for: .normal)
        subBtn.addTarget(self, action: #selector(AddTransactionVC.addMinusSymbol), for: .touchUpInside)

        let multiplyBtn = UIButton(frame: CGRect(x: (opView.frame.width / 6) * 4, y: 0, width: (opView.frame.width / 6), height: height))
        multiplyBtn.setImage(UIImage(named: "multiplyIcon"), for: .normal)
        multiplyBtn.addTarget(self, action: #selector(AddTransactionVC.addMultiplySymbol), for: .touchUpInside)

        let divideBtn = UIButton(frame: CGRect(x: (opView.frame.width / 6) * 5, y: 0, width: opView.frame.width / 6 , height: height))
        divideBtn.setImage(UIImage(named: "divideIcon"), for: .normal)
        divideBtn.addTarget(self, action: #selector(AddTransactionVC.addDivideSymbol), for: .touchUpInside)
        
        opView.addSubview(openParentheseBtn)
        opView.addSubview(closeParentheseBtn)
        opView.addSubview(addBtn)
        opView.addSubview(subBtn)
        opView.addSubview(multiplyBtn)
        opView.addSubview(divideBtn)

        amountTxt.inputAccessoryView = opView
        categoryBtn.titleLabel?.numberOfLines = 0
        categoryBtn.titleLabel?.lineBreakMode = .byWordWrapping
        CoreDataService.instance.fetchAccounts { (accounts) in
            accountsCount = accounts.count
            if accounts.count < 2 {
                accountFromBtn.isEnabled = false
                accountToBtn.isEnabled = false
            }
        }
        
        layoutCV.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layoutCV.minimumInteritemSpacing = 8
        layoutCV.minimumLineSpacing = 8
       
        tagImageView.frame = CGRect(x: 4, y: 3, width: 32, height: 24)
        
        if transaction == nil {
            typeBtn.setTitle(TransactionHelper.instance.currentType, for: .normal)
            setCategory()
            yesterdayBtn.setImage(nil, for: .normal)
            otherDateBtn.setImage(nil, for: .normal)
            
            if TransactionHelper.instance.currentType != TransactionType.transfer.rawValue {
                accountToBtn.isHidden = true
            }
            
            
            CoreDataService.instance.fetchAccount(ByObjectID: AccountHelper.instance.currentAccount ?? "") { (account) in
                self.accountFrom = account
                accountFromBtn.setTitle(accountFrom?.name, for: .normal)
                
                if let currency = self.accountFrom?.currency {
                    currencyBtn = UIButton(frame: CGRect(x: amountTxt.frame.width - 32, y: 0, width: 32, height: 40))
                    currencyBtn?.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
                    currencyBtn?.setTitleColor(#colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), for: .normal)
                    currencyBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
                    currencyBtn?.addTarget(self, action: #selector(AddTransactionVC.selectCurrency), for: .touchUpInside)
                    currencyBtn?.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
                    amountTxt.addSubview(currencyBtn!)
                }
            }
            
            //
           
            tagsCollectionView = UICollectionView(frame: CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: 0, height: 0), collectionViewLayout: layoutCV)
            tagsCollectionView?.dataSource = self
            tagsCollectionView?.delegate = self
            tagsCollectionView?.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
            tagsCollectionView?.showsVerticalScrollIndicator = false
            tagsCollectionView?.showsHorizontalScrollIndicator = false
            tagsCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            tagTxt = UITextField(frame: CGRect(x: 0, y: 3, width: scrollView.frame.width, height: 24))
            
            tagTxt.returnKeyType = .done
            tagTxt.leftView = tagImageView
            tagTxt.leftViewMode = .unlessEditing
            tagTxt.delegate = self
            scrollView.delegate = self
            scrollView.addSubview(tagsCollectionView!)
            scrollView.addSubview(tagTxt)
        } else {
            guard let transaction = self.transaction, let date = transaction.date, let description = transaction.desc, let category = transaction.category else {return}
            guard let account = transaction.account, let currency = account.currency else {return}
            self.expressionStr = "\(transaction.amount)"
            self.descriptionTxt.text = description
            self.category = category
            handleCategory(category)
            typeBtn.setTitle(transaction.type, for: .normal)
            accountToBtn.isHidden = true
            self.date = date
            if date.startOfDay() == Date().startOfDay() {
                setToday()
            } else if date.startOfDay() == (Date() - 86400).startOfDay() {
                setYesterday()
            } else {
                setOtherDay()
                otherDateBtn.setTitle(date.formatDateToStr(), for: .normal)
            }
            if transaction.transfer != nil {
                typeBtn.isEnabled = false
                categoryBtn.isEnabled = false
                accountFromBtn.isEnabled = false
                yesterdayBtn.isEnabled = false
                todayBtn.isEnabled = false
                otherDateBtn.isEnabled = false
            }
            accountToBtn.isHidden = true
            accountFrom = account
            accountFromBtn.setTitle(accountFrom?.name, for: .normal)
            currencyBtn = UIButton(frame: CGRect(x: amountTxt.frame.width - 32, y: 0, width: 32, height: 40))
            currencyBtn?.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
            currencyBtn?.setTitleColor(#colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), for: .normal)
            currencyBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
            currencyBtn?.addTarget(self, action: #selector(AddTransactionVC.selectCurrency), for: .touchUpInside)
            currencyBtn?.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
            amountTxt.addSubview(currencyBtn!)
            CoreDataService.instance.fetchTags(transaction: transaction) { (tags) in
                for item in tags {
                    if let name =  item.name {
                        self.tags.append((name, false))
                    }
                }
                let contentWidth = getTagsWith()
                tagsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 3, width: contentWidth, height: 24), collectionViewLayout: layoutCV)
                tagsCollectionView?.dataSource = self
                tagsCollectionView?.delegate = self
                tagsCollectionView?.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
                tagsCollectionView?.showsVerticalScrollIndicator = false
                tagsCollectionView?.showsHorizontalScrollIndicator = false
                tagsCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
                tagTxt.frame = CGRect(x: contentWidth, y: 3, width: contentWidth > (0.5*scrollView.frame.width) ? (0.5*scrollView.frame.width): scrollView.frame.width - contentWidth, height: 24)
                tagTxt.returnKeyType = .done
                tagTxt.leftView = tagImageView
                tagTxt.leftViewMode = .unlessEditing
                tagTxt.delegate = self
                scrollView.delegate = self
                scrollView.contentSize = CGSize(width: contentWidth + tagTxt.frame.width, height: 30)
                scrollView.addSubview(tagsCollectionView!)
                scrollView.addSubview(tagTxt)
            }
        }
    }
    func rebuildTagsUIElements(){
        let contentWidth = getTagsWith()
        tagsCollectionView?.frame = CGRect(x: 0, y: 3, width: contentWidth, height: 24)
        tagsCollectionView?.reloadData()
        tagTxt.frame = CGRect(x: contentWidth, y: (tagTxt.frame.origin.y), width: contentWidth > (0.5*scrollView.frame.width) ? (0.5*scrollView.frame.width): scrollView.frame.width - contentWidth, height: 24)
        scrollView.contentSize = CGSize(width: contentWidth + tagTxt.frame.width, height: 30)
        tagTxt.becomeFirstResponder()
    }
    func setCategory() {
        guard let typeText = typeBtn.titleLabel?.text else {return}
        switch typeText {
        case TransactionType.transfer.rawValue :
            CoreDataService.instance.fetchCategory(ByName: Constants.CATEGORY_TRANSFER, system: true) { (categories) in
                for item in categories {
                    handleCategory(item)
                }
            }
            accountToBtn.isHidden = false
            categoryBtn.isEnabled = false
            CoreDataService.instance.fetchAccount(bySystemName: Constants.NAME_FOR_EXTERNAL_ACCOUNT) { (externalAccounts) in
                for item in externalAccounts {
                    self.accountTo = item
                    accountToBtn.setTitle(item.name, for: .normal)
                }
            }
        default:
            if let currentCategory = CategoryHelper.instance.currentCAtegory {
                CoreDataService.instance.fetchCategory(ByObjectID: currentCategory) { (categoryFetched) in
                    if categoryFetched.systemName == Constants.CATEGORY_TRANSFER {
                        setWithoutCategory()
                    } else {
                        self.category = categoryFetched
                        handleCategory(categoryFetched)
                    }
                }
            } else {
                setWithoutCategory()
            }
            accountToBtn.isHidden = true
            categoryBtn.isEnabled = true
        }
    }
    
    func setWithoutCategory(){
        CoreDataService.instance.fetchCategory(ByName: "Without category",system: true, complition: { (categories) in
            for item in categories {
                self.category = item
                handleCategory(item)
            }
        })
    }
    
    
    
    @IBAction func openTypeBtnPressed(_ sender: Any) {
        let selectType = SelectTransactionTypeVC()
        selectType.delegate = self
        selectType.modalPresentationStyle = .custom
        presentDetail(selectType)
    }
    
    @IBAction func openCategoryBtnPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let categoryVC = storyBoard.instantiateViewController(withIdentifier: "CategoryVC") as? CategoryVC else {return}
        categoryVC.delegate = self
        presentDetail(categoryVC)
    }
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    func checkAndSetLastMathSymbolInExpression(symbol: String){
        var mathSymbolPresented = false
        if self.expressionStr.count == 0  {
            if (symbol == "(" || symbol == "-") {
                self.expressionStr = symbol
                return
            }
        } else {
            for item in Constants.allowedMathSymbolsForEvaluationInExpression {
                if item != "(" && item != ")" {
                    if self.expressionStr.hasSuffix(item) {
                        mathSymbolPresented = true
                    }
                }
            }
            if mathSymbolPresented {
                self.expressionStr = "\(self.expressionStr.dropLast())\(symbol)"
            } else {
                self.expressionStr += symbol
            }
        }
    }
    @objc func addOpenParenthese(){
        checkAndSetLastMathSymbolInExpression(symbol: "(")
    }
    @objc func addCloseParenthese(){
        checkAndSetLastMathSymbolInExpression(symbol: ")")
    }
    @objc func addPlusSymbol(){
        checkAndSetLastMathSymbolInExpression(symbol: "+")
    }
    @objc func addMinusSymbol(){
        checkAndSetLastMathSymbolInExpression(symbol: "-")
    }
    @objc func addMultiplySymbol(){
        checkAndSetLastMathSymbolInExpression(symbol: "*")
    }
    @objc func addDivideSymbol(){
        checkAndSetLastMathSymbolInExpression(symbol: "/")
    }
    
    @objc func textFieldDidChange(){
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
    func saveTransactionTags(transaction: Transaction, tags: [(name: String, selected: Bool)]){
        for item in tags {
            CoreDataService.instance.fetchTag(name: item.name, transaction: transaction) { (tag) in
                if tag.count == 0 {
                     CoreDataService.instance.saveTag(name: item.name, transaction: transaction)
                }
            }
        }
    }
    
    func saveTransferTransactions(amount: Double, amountWithCurrencyRate: Double, accountFrom: Account, accountTo: Account, category: Category){
        
        CoreDataService.instance.saveTransaction(amount: amount, desc: self.descriptionTxt.text, type: TransactionType.expance.rawValue , date: self.date, latitude: self.latitude, longitude: self.longitude, place: self.place, account: accountFrom, category: category, transfer: nil) { (transaction) in
            saveTransactionTags(transaction: transaction, tags: self.tags)
            for photo in self.photos {
                CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transaction)
            }
            
            CoreDataService.instance.saveTransaction(amount: amountWithCurrencyRate.roundTo(places: 2), desc: self.descriptionTxt.text, type: TransactionType.income.rawValue , date: self.date, latitude: self.latitude, longitude: self.longitude, place: self.place, account: accountTo, category: category, transfer: transaction) { (transferTransaction) in
                saveTransactionTags(transaction: transferTransaction, tags: self.tags)
                for photo in self.photos {
                    CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transferTransaction)
                }
                self.delegate?.handleTransaction()
                self.dismissDetail()
            }
            
        }
    }
    
    @IBAction func saveTransactionBtnPressed(_ sender: Any) {
        let amount = amountForAccountCurrency
        if amount == 0 {return}
        
        guard let type = typeBtn.titleLabel?.text else {return}
        guard let accountFrom = self.accountFrom else {return}
        guard let category = self.category else {return}
        
         if transaction == nil {
            TransactionHelper.instance.currentType = type
            if type == TransactionType.transfer.rawValue {
                guard let accountTo = self.accountTo else {return}
                guard let currencyFrom = accountFrom.currency else {return}
                guard let currencyTo = accountTo.currency else {return}
                if currencyFrom == currencyTo {
                    self.saveTransferTransactions(amount: amount, amountWithCurrencyRate: amount, accountFrom: accountFrom, accountTo: accountTo, category: category)
                } else {
                    CoreDataService.instance.fetchCurrencyRate(base: currencyFrom, pair: currencyTo, date: date) { (currencyRates) in
                        if currencyRates.count > 0 {
                            if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: currencyFrom, pair: currencyTo, rates: currencyRates) {
                                let amountWithCurrencyRate = currencyRate * amount
                                self.saveTransferTransactions(amount: amount, amountWithCurrencyRate: amountWithCurrencyRate, accountFrom: accountFrom, accountTo: accountTo, category: category)
                            } else {
                                print("Can`t evaluate currency rate for \(currencyFrom):\(currencyTo)")
                            }
                        } else {
                            if  Date().startOfDay() <= self.date {
                                ExchangeService.instance.getCurrencyRateByAPILatest(complition: { (success) in
                                    if success {
                                        CoreDataService.instance.fetchCurrencyRate(base: currencyFrom, pair: currencyTo, date: self.date) { (currencyRates) in
                                            if currencyRates.count > 0 {
                                                if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: currencyFrom, pair: currencyTo, rates: currencyRates) {
                                                    let amountWithCurrencyRate = currencyRate * amount
                                                    self.saveTransferTransactions(amount: amount, amountWithCurrencyRate: amountWithCurrencyRate, accountFrom: accountFrom, accountTo: accountTo, category: category)
                                                } else {
                                                    print("Can`t evaluate currency rate for \(currencyFrom):\(currencyTo)")
                                                }
                                            }
                                        }
                                        
                                    }
                                })
                            } else {
                                ExchangeService.instance.getHistoricalCurrencyRate(date: self.date, complition: { (success) in
                                    if success {
                                        CoreDataService.instance.fetchCurrencyRate(base: currencyFrom, pair: currencyTo, date: self.date) { (currencyRates) in
                                            if currencyRates.count > 0 {
                                                if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: currencyFrom, pair: currencyTo, rates: currencyRates) {
                                                    let amountWithCurrencyRate = currencyRate * amount
                                                    self.saveTransferTransactions(amount: amount, amountWithCurrencyRate: amountWithCurrencyRate, accountFrom: accountFrom, accountTo: accountTo, category: category)
                                                } else {
                                                    print("Can`t evaluate currency rate for \(currencyFrom):\(currencyTo)")
                                                }
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                CoreDataService.instance.saveTransaction(amount: amount, desc: descriptionTxt.text, type: type, date: date, latitude: latitude, longitude: longitude, place: place, account: accountFrom, category: category, transfer: nil) { (transaction) in
                    saveTransactionTags(transaction: transaction, tags: self.tags)
                    for photo in photos {
                        CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transaction)
                    }
                    delegate?.handleTransaction()
                    dismissDetail()
                }
            }
        } else {
            if let transaction = self.transaction {
                transaction.amount = amount
                transaction.type = type
                transaction.category = category
                transaction.desc = descriptionTxt.text
                transaction.date = date
                transaction.account = accountFrom
                CoreDataService.instance.update { (success) in
                    if success {
                        saveTransactionTags(transaction: transaction, tags: self.tags)
                        dismissDetail()
                    }
                }
            }
        }
    }
    
    func setYesterday(){
        yesterdayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
    }
    
    func setToday() {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
    }
    
    func setOtherDay() {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
    }
    
    @IBAction func yesterdayBtnPressed(_ sender: Any) {
        setYesterday()
        date = Date() - 86400
    }
    
    @IBAction func todayBtnPressed(_ sender: Any) {
        setToday()
        date = Date()
    }
    
    @IBAction func otherDateBtnPressed(_ sender: Any) {
        setOtherDay()
        let calendarVC = CalendarVC()
        calendarVC.delegate = self
        calendarVC.modalPresentationStyle = .custom
        presentDetail(calendarVC )
    }
    
    @IBAction func accountFromBtnPressed(_ sender: Any) {
        let selectAccountVC = SelectAccountVC()
        selectAccountVC.delegate = self
        if let hidenAccount = accountTo {
            selectAccountVC.hidenAccounts.append(hidenAccount)
        }
        selectAccountVC.transactionDirection = TransactionDirection.from
        selectAccountVC.modalPresentationStyle = .custom
        presentDetail(selectAccountVC)
    }
    @IBAction func accountToBtnPressed(_ sender: Any) {
        let selectAccountVC = SelectAccountVC()
        selectAccountVC.delegate = self
        if let hidenAccount = accountFrom {
            selectAccountVC.hidenAccounts.append(hidenAccount)
        }
        selectAccountVC.transactionDirection = TransactionDirection.to
        selectAccountVC.modalPresentationStyle = .custom
        presentDetail(selectAccountVC)
    }
    
    func createDescriptionForCurrencyRate(baseCurrencyCode: String, pairCurrencyCode: String, rate: Double, amount: Double) -> String{
        let transormedValue = EncodeDecodeService.instance.transformCurrencyRate(value: rate)
        let currencyRateDesc = "\(amount.roundTo(places: 2))\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: pairCurrencyCode)) (\(transormedValue.multiplier)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: baseCurrencyCode)) = \(transormedValue.newValue.roundTo(places: 2))\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: pairCurrencyCode)))"
        return currencyRateDesc
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: scrollView.frame.width, height: 24)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        guard let attributes = [NSAttributedStringKey.font:  UIFont(name: "Avenir-Book", size: 17)] as? [NSAttributedStringKey: Any] else {return CGRect(x: 0, y: 0, width: 70, height: 24)}
        return NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    func getTagsWith() -> CGFloat{
        var width = CGFloat(0)
        for item in tags {
            width += estimatedFrameForText(text: item.name).width + 32
        }
        return width
    }
    
}

extension AddTransactionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentSize.height = 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = tagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell {
            cell.configureCell(title: tags[indexPath.row].name, selected: tags[indexPath.row].selected)
            cell.closeBtn.tag = indexPath.row
            cell.closeBtn.addTarget(self, action: #selector(AddTransactionVC.handleCellCloseBtnPressed), for: UIControlEvents.touchUpInside)
            return cell
        }
        return UICollectionViewCell()
    }
    
    @objc func handleCellCloseBtnPressed(sender : UIButton!){
        guard let transaction = self.transaction else {
            tags.remove(at: sender.tag)
            rebuildTagsUIElements()
            tagsCollectionView?.reloadData()
            return
        }
        CoreDataService.instance.fetchTag(name: tags[sender.tag].name, transaction: transaction) { (tag) in
            if tag.count > 0 {
                CoreDataService.instance.removeTag(tag: tag[0])
            }
            tags.remove(at: sender.tag)
            rebuildTagsUIElements()
            tagsCollectionView?.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = estimatedFrameForText(text: tags[indexPath.row].name).width + 24
        return CGSize(width: width, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = tagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell {
            deselectAllcell()
            tags[indexPath.row].selected = true
            collectionView.reloadData()
        }
    }
    
    func deselectAllcell(){
        for (index, value) in self.tags.enumerated() {
            let item = (value.name, false)
            tags.remove(at: index)
            tags.insert(item, at: index)
        }
    }
    
}

extension AddTransactionVC: UITextFieldDelegate, TransactionProtocol, CategoryProtocol, CalendarProtocol, AccountProtocol {
    func handleCarrency(_ currency: String, currencyRate: Double) {
        guard let accountCurrency = accountFrom?.currency else {return}
        self.currencyBtn?.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
        self.currencyForExchange = currency
        self.currencyRateForExchange = currencyRate
        self.amountForAccountCurrency = amount * currencyRate
         self.amountForAccountCurrency =  self.amountForAccountCurrency.roundTo(places: 2)
        self.currencyRateLbl.text = self.createDescriptionForCurrencyRate(baseCurrencyCode: currency, pairCurrencyCode: accountCurrency, rate: currencyRate, amount: amountForAccountCurrency)
        self.currencyRateLbl.isHidden = false
        
    }

    
    func handleAccountType(_ type: String) {
        
    }
    
    func handleAccountFrom(_ account: Account) {
        self.accountFrom = account
        accountFromBtn.setTitle(account.name, for: .normal)
    }
    
    func handleAccountTo(_ account: Account) {
        self.accountTo = account
        accountToBtn.setTitle(account.name, for: .normal)
    }
    
    func handleDate(_ date: Date) {
        self.date = date
        otherDateBtn.setTitle(date.formatDateToStr(), for: .normal)
    }
    
    func handleTransactionType(_ type: String) {
        typeBtn.setTitle(type, for: .normal)
        setCategory()
    }
    
    func handleCategory(_ category: Category) {
        self.category = category
        categoryBtn.setTitle(CategoryHelper.instance.textNameCategory(category: category), for: .normal)
        categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: category.color)
        if category.systemName != Constants.CATEGORY_TRANSFER {
            CategoryHelper.instance.currentCAtegory = category.objectID.uriRepresentation().absoluteString
        }
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagTxt {
            if let text = textField.text {
                if !text.isEmpty {
                    tags.append((text, false))
                    rebuildTagsUIElements()
                    tagTxt.text = ""
                } else {
                    self.view.endEditing(true)
                }
            } else {
                self.view.endEditing(true)
            }
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTxt {
            if string.count == 0{
                if self.expressionStr.count > 1 {
                    self.expressionStr = "\(self.expressionStr.dropLast())"
                } else {
                    self.expressionStr = ""
                }
            } else {
                if Constants.allowedSDigits.contains(string) {
                    expressionStr += string
                } else if (Constants.allowedMathSymbolsForEvaluationInExpression.contains(string) || Constants.dotSymbol == string) && !expressionStr.hasSuffix(string){
                        expressionStr += string
                }
            }
            return false
        } else {
            return true
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tagTxt {
            tagTxt.leftView = tagImageView
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tagTxt {
            tagTxt.leftView = nil
        }
        return true
    }
}
