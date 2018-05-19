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

    
    @IBOutlet weak var photoView: UIView!
    @IBAction func infoBtnPressed(_ sender: Any) {
        let addTransactionAdditionalVC = AddTransactionAdditionalVC()
        addTransactionAdditionalVC.delegate = self
        addTransactionAdditionalVC.addTransactionVC = self
        addTransactionAdditionalVC.amount = amountForAccountCurrency
        addTransactionAdditionalVC.date = self.date
        addTransactionAdditionalVC.desc = self.desc
        addTransactionAdditionalVC.transaction = self.transaction
        addTransactionAdditionalVC.photos = self.photos
        addTransactionAdditionalVC.tags = self.tags
        addTransactionAdditionalVC.place = self.place
        addTransactionAdditionalVC.modalPresentationStyle = .custom
        self.presentDetail(nextViewController!, animated: true)
    }
    

    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var openParentheseBtn: UIButton!
    @IBOutlet weak var closeParentheseBtn: UIButton!
    @IBOutlet weak var addSignBtn: UIButton!
    @IBOutlet weak var minusSignBtn: UIButton!
    @IBOutlet weak var multiplySignBtn: UIButton!
    @IBOutlet weak var divedeSignBtn: UIButton!
    @IBOutlet weak var dotSignBtn: UIButton!
    @IBOutlet weak var deleteSignBtn: UIButton!
    @IBOutlet weak var zeroDigitBtn: UIButton!
    @IBOutlet weak var oneDigitBtn: UIButton!
    @IBOutlet weak var twoDigitBtn: UIButton!
    @IBOutlet weak var threeDigitBtn: UIButton!
    @IBOutlet weak var fourDigitBtn: UIButton!
    @IBOutlet weak var fiveDigitBtn: UIButton!
    @IBOutlet weak var sixDigitBtn: UIButton!
    @IBOutlet weak var sevenDigitBtn: UIButton!
    @IBOutlet weak var eightDigitBtn: UIButton!
    @IBOutlet weak var nineDigitBtn: UIButton!
    
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var transferImg: UIImageView!
    @IBOutlet weak var typeSG: UISegmentedControl!
    @IBOutlet weak var amountLbl: UILabel!
    
    
    

    @IBOutlet weak var accountFromBtn: UIButton!
    @IBOutlet weak var accountToBtn: UIButton!
    @IBOutlet weak var expressionLbl: UILabel!
    @IBOutlet weak var currencyRateLbl: UILabel!
    

    @IBOutlet weak var accountFromTypeImgView: UIImageView!
    @IBOutlet weak var accountToTypeImgView: UIImageView!
    @IBOutlet weak var currencyBtn: UIButton!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var bookmarkView: UIView!
    
    
    
    var isPresenting: Bool = true
    var interactiveTransition: UIPercentDrivenInteractiveTransition!
    var nextViewController: AddTransactionAdditionalVC?
    var shouldComplete = false
    var lastProgress: CGFloat?
    
    var place: Place?
    var desc: String = ""
    var transaction: Transaction?
    let height: CGFloat = 40.0
    var category: Category?
    var date = Date()
    var tags = [(name: String, selected: Bool)]()
    var photos = [[String: UIImage]]()
    var accountFrom: Account?
    var accountTo: Account?
    var accountsCount = 0
    var currencyForExchange = ""
    var currencyRateForExchange = 1.0
    var amountForAccountCurrency = 0.0
    
    var delegate: BriefProtocol?
    var amount: Double {
        get{
            let value = amountLbl.text ?? ""
            return Double(value) ?? 0.0
        }
        set{
            amountLbl.text = "\(newValue.roundTo(places: 2))"
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
                currencyRateLbl.isHidden = true
                self.amount = 0.0
            } else {
                expressionLbl.isHidden = false
                if currencyRateForExchange != 1 {
                    currencyRateLbl.isHidden = false
                } else {
                    currencyRateLbl.isHidden = true
                }
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
    
    @IBAction func typeSGChanged(_ sender: Any) {
        setCategory()
    }
    @IBAction func currencyBtnPressed(_ sender: Any) {
        guard let currencyCode = accountFrom?.currency else {return}
        let selectCurrency = SelectCurrencyVC()
        selectCurrency.date = date
        selectCurrency.modalPresentationStyle = .custom
        selectCurrency.pairCurrency = currencyCode
        selectCurrency.delegate = self
        present(selectCurrency , animated: false, completion: nil)
    }
    
    
    func setUpUIElements(){
        amountLbl.text = "0"
        currencyBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        categoryBtn.titleLabel?.numberOfLines = 0
        categoryBtn.titleLabel?.lineBreakMode = .byWordWrapping
        CoreDataService.instance.fetchAccounts { (accounts) in
            accountsCount = accounts.count
            if accounts.count < 2 {
                accountFromBtn.isEnabled = false
                accountToBtn.isEnabled = false
            }
        }
    
        if transaction == nil {
            typeSG.selectedSegmentIndex = 0
            setCategory()
            
            if TransactionHelper.instance.currentType != TransactionType.transfer.rawValue {
                accountToBtn.isHidden = true
            }
            
            
            CoreDataService.instance.fetchAccount(ByObjectID: AccountHelper.instance.currentAccount ?? "") { (account) in
                self.accountFrom = account
                accountFromBtn.setTitle(accountFrom?.name, for: .normal)
                if account.type == AccountType.Cash.rawValue {
                    accountFromTypeImgView.image = UIImage(named: "CoinsIcon")
                } else {
                    accountFromTypeImgView.image = UIImage(named: "CardIcon")
                }
                if let currency = self.accountFrom?.currency {
                    currencyBtn.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
                }
            }
        } else {
            guard let transaction = self.transaction, let date = transaction.date, let description = transaction.desc, let category = transaction.category else {return}
            guard let account = transaction.account, let currency = account.currency else {return}
            self.expressionStr = "\(transaction.amount)"
            self.desc = description
            self.category = category
            self.place = transaction.place
            
            handleCategory(category)
            typeSG.selectedSegmentIndex = transaction.type == TransactionType.income.rawValue ? 0 : 1
            self.date = date
            if transaction.transfer != nil {
                typeSG.isEnabled = false
                accountFromBtn.isEnabled = false
                accountToBtn.isEnabled = false
                accountToBtn.isHidden = false
                if let accountTo = transaction.transfer?.account {
                    accountToBtn.setTitle(accountTo.name, for: .normal)
                    accountToTypeImgView.isHidden = false
                    if accountTo.type == AccountType.Cash.rawValue {
                        accountToTypeImgView.image = UIImage(named: "CoinsIcon")
                    } else {
                        accountToTypeImgView.image = UIImage(named: "CardIcon")
                    }
                }
                categoryBtn.isHidden = true
                transferImg.image = UIImage(named: "ArrowRightIcon")
                transferImg.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                transferImg.layer.cornerRadius = 0
                openParentheseBtn.isEnabled = false
                closeParentheseBtn.isEnabled = false
                addSignBtn.isEnabled = false
                minusSignBtn.isEnabled = false
                multiplySignBtn.isEnabled = false
                divedeSignBtn.isEnabled = false
                zeroDigitBtn.isEnabled = false
                oneDigitBtn.isEnabled = false
                twoDigitBtn.isEnabled = false
                threeDigitBtn.isEnabled = false
                fourDigitBtn.isEnabled = false
                fiveDigitBtn.isEnabled = false
                sixDigitBtn.isEnabled = false
                sevenDigitBtn.isEnabled = false
                eightDigitBtn.isEnabled = false
                nineDigitBtn.isEnabled = false
                dotSignBtn.isEnabled = false
                deleteSignBtn.isEnabled = false
                currencyBtn.isEnabled = false
            } else {
               accountToBtn.isHidden = true
            }
            
            accountFrom = account
            if account.type == AccountType.Cash.rawValue {
                accountFromTypeImgView.image = UIImage(named: "CoinsIcon")
            } else {
                accountFromTypeImgView.image = UIImage(named: "CardIcon")
            }
            accountFromBtn.setTitle(accountFrom?.name, for: .normal)
            currencyBtn.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
            CoreDataService.instance.fetchTags(transaction: transaction) { (tags) in
                for item in tags {
                    if let name =  item.name {
                        self.tags.append((name, false))
                    }
                }

            }
            CoreDataService.instance.fetchPhotos(transaction: transaction) { (photos) in
                for item in photos {
                    guard let data = item.data, let name = item.name else {continue}
                    guard let image = UIImage(data: data) else {continue}
                    self.photos.append([name : image])
                }
            }
        }
        nextViewController = AddTransactionAdditionalVC()
        nextViewController?.transitioningDelegate = self
        nextViewController?.modalPresentationStyle = .custom
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(pan:)))
        infoBtn.addGestureRecognizer(pan)
    }
   
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view?.superview)
        //Represents the percentage of the transition that must be completed before allowing to complete.
        let percentThreshold: CGFloat = 0.2
        //Represents the difference between progress that is required to trigger the completion of the transition.
        let automaticOverrideThreshold: CGFloat = 0.03
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width - infoBtn.frame.width
        let dragAmount: CGFloat = (nextViewController == nil) ? screenWidth : -screenWidth
        var progress: CGFloat = 1.0 * translation.x  / dragAmount
        progress = fmax(progress, 0)
        progress = fmin(progress, 1)
        
        switch pan.state {
        case .began:
            self.nextViewController?.delegate = self
            self.nextViewController?.addTransactionVC = self
            self.nextViewController?.amount = amountForAccountCurrency
            self.nextViewController?.date = self.date
            self.nextViewController?.desc = self.desc
            self.nextViewController?.transaction = self.transaction
            self.nextViewController?.photos = self.photos
            self.nextViewController?.tags = self.tags
            self.nextViewController?.place = self.place
            present(nextViewController!, animated: true, completion: nil)
//            performSegue(withIdentifier: "show", sender: self)
        case .changed:
            guard let lastProgress = lastProgress else {return}
            
            // When swiping back
            if lastProgress > progress {
                shouldComplete = false
                // When swiping quick to the right
            } else if progress > lastProgress + automaticOverrideThreshold {
                shouldComplete = true
            } else {
                // Normal behavior
                shouldComplete = progress > percentThreshold
            }
            interactiveTransition.update(progress)
            
        case .ended, .cancelled:
            if pan.state == .cancelled || shouldComplete == false {
                interactiveTransition.cancel()
            } else {
                interactiveTransition.finish()
            }
            
        default:
            break
        }
        
        lastProgress = progress
    }
    
    func setCategory() {
        switch typeSG.selectedSegmentIndex {
        case 2 :
            CoreDataService.instance.fetchCategory(ByName: Constants.CATEGORY_TRANSFER, system: true) { (categories) in
                for item in categories {
                    handleCategory(item)
                }
            }
            accountToBtn.isHidden = false
            accountToTypeImgView.isHidden = false
            categoryBtn.isHidden = true
            transferImg.image = UIImage(named: "ArrowRightIcon")
            transferImg.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            transferImg.layer.cornerRadius = 0
            CoreDataService.instance.fetchAccount(bySystemName: Constants.NAME_FOR_EXTERNAL_ACCOUNT) { (externalAccounts) in
                for item in externalAccounts {
                    self.accountTo = item
                    if item.type == AccountType.Cash.rawValue {
                        accountToTypeImgView.image = UIImage(named: "CoinsIcon")
                    } else {
                        accountToTypeImgView.image = UIImage(named: "CardIcon")
                    }
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
            accountToTypeImgView.isHidden = true
            categoryBtn.isHidden = false
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
    
    @IBAction func addOpenParenthese(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: "(")
    }
    
    @IBAction func addCloseParenthese(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: ")")
    }
    
    @IBAction func addPlusSymbol(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: "+")
    }
    
    @IBAction func addMinusSymbol(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: "-")
    }
    
    @IBAction func addMultiplySymbol(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: "*")
    }
    
    @IBAction func addDivideSymbol(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: "/")
    }
    
    

    
    
    @IBAction func addDigit(_ sender: UIButton) {
       expressionStr +=  "\(sender.tag)"
    }
    @IBAction func addDot(_ sender: Any) {
        checkAndSetLastMathSymbolInExpression(symbol: ".")
    }
    @IBAction func deleteSymbol(_ sender: Any) {
        if self.expressionStr.count > 1 {
            self.expressionStr = "\(self.expressionStr.dropLast())"
        } else {
            self.expressionStr = ""
        }
    }
    
    
    
    
    
    @objc func textFieldDidChange(){
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
    func saveTransactionTags(transaction: Transaction, tags: [(name: String, selected: Bool)]){
        for item in tags {
            CoreDataService.instance.fetchTag(name: item.name, transaction: transaction) { (tag) in
                if tag.count == 0 {
                     CoreDataService.instance.saveTag(name: item.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), transaction: transaction)
                }
            }
        }
    }
    
    func saveTransactionPhotos(transaction: Transaction, photos: [[String : UIImage]]){
        for (index, item) in photos.enumerated() {
            for photo in item {
                if photo.key.isEmpty {
                    let name = date.description + "\(index)"
                    CoreDataService.instance.savePhoto(name: name, image: photo.value, transaction: transaction)
                }
            }
        }
    }
    
    func saveTransferTransactions(amount: Double, amountWithCurrencyRate: Double, accountFrom: Account, accountTo: Account, category: Category){
        
        CoreDataService.instance.saveTransaction(amount: amount, desc: self.desc, type: TransactionType.costs.rawValue , date: self.date, place: self.place, account: accountFrom, category: category, transfer: nil) { (transaction) in
            saveTransactionTags(transaction: transaction, tags: self.tags)
            saveTransactionPhotos(transaction: transaction, photos: self.photos)
            
            CoreDataService.instance.saveTransaction(amount: amountWithCurrencyRate.roundTo(places: 2), desc: self.desc, type: TransactionType.income.rawValue , date: self.date, place: self.place, account: accountTo, category: category, transfer: transaction) { (transferTransaction) in
                saveTransactionTags(transaction: transferTransaction, tags: self.tags)
                saveTransactionPhotos(transaction: transferTransaction, photos: self.photos)
                self.delegate?.handleTransaction(date: self.date)
                self.dismissDetail()
            }
            
        }
    }
    
    func saveTransaction(){
        let amount = amountForAccountCurrency
        if amount == 0 {return}
        let type = typeSG.selectedSegmentIndex == 0 ? TransactionType.income.rawValue : typeSG.selectedSegmentIndex == 1 ? TransactionType.costs.rawValue: TransactionType.transfer.rawValue
        guard let accountFrom = self.accountFrom else {return}
        guard let category = self.category else {return}
        if let place = self.place {
            place.date = Date()
            CoreDataService.instance.update { (success) in
                if success {}
            }
        }
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
                CoreDataService.instance.saveTransaction(amount: amount, desc: self.desc, type: type, date: date, place: place, account: accountFrom, category: category, transfer: nil) { (transaction) in
                    saveTransactionTags(transaction: transaction, tags: self.tags)
                    saveTransactionPhotos(transaction: transaction, photos: self.photos)
                    delegate?.handleTransaction(date: self.date)
                    dismissDetail()
                }
            }
        } else {
            if let transaction = self.transaction {
                transaction.amount = amount
                transaction.type = type
                transaction.category = category
                transaction.desc = self.desc
                transaction.date = date
                transaction.account = accountFrom
                transaction.place = self.place
                CoreDataService.instance.update { (success) in
                    if success {
                        saveTransactionTags(transaction: transaction, tags: self.tags)
                        saveTransactionPhotos(transaction: transaction, photos: self.photos)
                        delegate?.handleTransaction(date: self.date)
                        dismissDetail()
                    }
                }
            }
        }
    }
    
    @IBAction func saveTransactionBtnPressed(_ sender: Any) {
        saveTransaction()
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as?  AddTransactionAdditionalVC {
            nextVC.delegate = self
            nextVC.addTransactionVC = self
            nextVC.amount = self.amountForAccountCurrency
            nextVC.date = self.date
            nextVC.desc = self.desc
            nextVC.transaction = self.transaction
            nextVC.photos = self.photos
            nextVC.tags = self.tags
            nextVC.place = self.place
        }
    }
}


extension AddTransactionVC: TransactionProtocol, CategoryProtocol, AccountProtocol{
    func handleAdditionalInfo(place: Place?, desc: String, date: Date, tags: [(name: String, selected: Bool)], photos: [[String : UIImage]]) {
        self.place = place
        self.desc = desc
        self.date = date
        self.tags = tags
        self.photos = photos
    }
    

    
    func setUIByCarrency(_ currency: String, currencyRate: Double, showCurrencyRate: Bool = true) {
        guard let accountCurrency = accountFrom?.currency else {return}
        self.currencyBtn.setTitle(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency), for: .normal)
        self.currencyForExchange = currency
        self.currencyRateForExchange = currencyRate
        self.amountForAccountCurrency = amount * currencyRate
        self.amountForAccountCurrency =  self.amountForAccountCurrency.roundTo(places: 2)
        self.currencyRateLbl.text = self.createDescriptionForCurrencyRate(baseCurrencyCode: currency, pairCurrencyCode: accountCurrency, rate: currencyRate, amount: amountForAccountCurrency)
        if showCurrencyRate {
            if amount == 0 || currencyRateForExchange == 1{
                self.currencyRateLbl.isHidden = true
            } else {
                    self.currencyRateLbl.isHidden = false
            }
        } else {
            self.currencyRateLbl.isHidden = true
        }
        
        
    }
    
    func handleCurrency(_ currency: String, currencyRate: Double) {
        setUIByCarrency(currency, currencyRate: currencyRate)
        
    }

    
    func handleAccountType(_ type: String) {
        
    }
    
    func handleAccountFrom(_ account: Account) {
        self.accountFrom = account
        if account.type == AccountType.Cash.rawValue {
            accountFromTypeImgView.image = UIImage(named: "CoinsIcon")
        } else {
            accountFromTypeImgView.image = UIImage(named: "CardIcon")
        }
        accountFromBtn.setTitle(account.name, for: .normal)
        guard let currency = accountFrom?.currency else {return}
        setUIByCarrency(currency, currencyRate: 1.0, showCurrencyRate: false)
    }
    
    func handleAccountTo(_ account: Account) {
        self.accountTo = account
        if account.type == AccountType.Cash.rawValue {
            accountToTypeImgView.image = UIImage(named: "CoinsIcon")
        } else {
            accountToTypeImgView.image = UIImage(named: "CardIcon")
        }
        accountToBtn.setTitle(account.name, for: .normal)
    }

    
    func handleTransactionType(_ type: String) {
    }
    
    func handleCategory(_ category: Category) {
        self.category = category
        accountToTypeImgView.isHidden = true
        categoryBtn.setTitle(CategoryHelper.instance.textNameCategory(category: category), for: .normal)
        let  color = EncodeDecodeService.instance.returnUIColor(components: category.color)
        transferImg.backgroundColor = color
        transferImg.image = nil
        transferImg.layer.cornerRadius = 8
        if category.systemName != Constants.CATEGORY_TRANSFER {
            CategoryHelper.instance.currentCAtegory = category.id
        }
    }
}

extension AddTransactionVC: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition = UIPercentDrivenInteractiveTransition()
        //Setting the completion speed gets rid of a weird bounce effect bug when transitions complete
        interactiveTransition.completionSpeed = 0.99
        return interactiveTransition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                return
        }
        let fakeBookmarkImgView = UIImageView(frame: CGRect(x: 0, y: amountView.frame.origin.y + bookmarkView.frame.origin.y, width: bookmarkView.frame.width, height: bookmarkView.frame.height))
        fakeBookmarkImgView.image = UIImage(named: "BookmarkIcon")
        
        if (isPresenting) {
            let fromRect = transitionContext.initialFrame(for: fromVC)
            var toRect = fromRect
            toRect.origin.x = toRect.size.width
            toVC.view.frame = toRect
            fakeBookmarkImgView.frame.origin.x = toRect.origin.x - infoBtn.frame.width
            containerView.addSubview(fakeBookmarkImgView)
            containerView.addSubview(toVC.view)
            UIView.animate(withDuration: 0.4, animations: {
                toVC.view.frame = fromRect
                fakeBookmarkImgView.frame.origin.x = fromRect.origin.x - self.infoBtn.frame.width
            }, completion: { _ in
                fakeBookmarkImgView.removeFromSuperview()
                if transitionContext.transitionWasCancelled {
                    transitionContext.completeTransition(false)
                } else {
                    transitionContext.completeTransition(true)
                }
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                fromVC.view.alpha = 0
            }, completion: { _ in
                
                transitionContext.completeTransition(true)
                fromVC.view.removeFromSuperview()
            })
        }
    }
}
