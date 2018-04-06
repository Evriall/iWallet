//
//  AddTransactionVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddTransactionVC: UIViewController {

    @IBOutlet weak var amountTxt: UITextField!
    
    @IBOutlet weak var accountsStackView: UIStackView!
    @IBOutlet weak var descriptionTxt: UITextField!
    @IBOutlet weak var typeBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryImg: UIImageView!
    
    @IBOutlet weak var tagsTxt: UITextField!
    
    @IBOutlet weak var yesterdayBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var otherDateBtn: UIButton!
    @IBOutlet weak var accountFromBtn: ButtonWithLeftImage!
    @IBOutlet weak var accountToBtn: ButtonWithLeftImage!
    
    let height: CGFloat = 40.0
    var category: Category?
    var date = Date()
    var tags = [String]()
    var photos = [String: UIImage]()
    var latitude = ""
    var longitude = ""
    var place = ""
    var accountFrom: Account?
    var accountTo: Account?
    var accountsCount = 0
    
    var delegate: BriefProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
    }
    

    
    func setUpUIElements(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddTransactionVC.handleTap))
        view.addGestureRecognizer(tap)
        amountTxt.addTarget(self, action: #selector(AddTransactionVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        amountTxt.delegate = self
        descriptionTxt.delegate = self
        tagsTxt.delegate = self
        let opView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height))
          opView.backgroundColor =  #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.8470588235, alpha: 1)
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
        descriptionTxt.inputAccessoryView = opView
        tagsTxt.inputAccessoryView = opView
 
        categoryBtn.titleLabel?.numberOfLines = 0
        categoryBtn.titleLabel?.lineBreakMode = .byWordWrapping
        typeBtn.setTitle(TransactionHelper.instance.currentType, for: .normal)
        setCategory()
      yesterdayBtn.setImage(nil, for: .normal)
      otherDateBtn.setImage(nil, for: .normal)
        
        if TransactionHelper.instance.currentType != TransactionType.transfer.rawValue {
            accountToBtn.isHidden = true
        }
        CoreDataService.instance.fetchAccounts { (accounts) in
            accountsCount = accounts.count
            if accounts.count < 2 {
                accountFromBtn.isEnabled = false
                accountToBtn.isEnabled = false
            }
        }
        
        CoreDataService.instance.fetchAccount(ByObjectID: AccountHelper.instance.currentAccount ?? "") { (account) in
            self.accountFrom = account
            accountFromBtn.setTitle(accountFrom?.name, for: .normal)
        }
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
    @objc func addOpenParenthese(){
   
    }
    @objc func addCloseParenthese(){
        
    }
    @objc func addPlusSymbol(){
        
    }
    @objc func addMinusSymbol(){
        
    }
    @objc func addMultiplySymbol(){
        
    }
    @objc func addDivideSymbol(){
        
    }
    
    @objc func textFieldDidChange(){
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func saveTransactionBtnPressed(_ sender: Any) {
        guard let amountText = amountTxt.text, let amount = Double(amountText), amount != 0 else {return}
        guard let type = typeBtn.titleLabel?.text else {return}
        guard let accountFrom = self.accountFrom else {return}
        guard let accountTo = self.accountTo else {return}
        guard let category = self.category else {return}
        
        TransactionHelper.instance.currentType = type
        if type == TransactionType.transfer.rawValue {
            guard let currencyFrom = accountFrom.currency else {return}
            guard let currencyTo = accountTo.currency else {return}
            var currencyRate = 1.0
            CoreDataService.instance.fetchCurrencyRate(base: currencyFrom, pair: currencyTo) { (currencyRates) in
                for item in currencyRates {
                    currencyRate = item.rate
                }
                let amountWithCurrencyRate = amount * currencyRate
                CoreDataService.instance.saveTransaction(amount: amount, desc: self.descriptionTxt.text, type: TransactionType.expance.rawValue , date: self.date, latitude: self.latitude, longitude: self.longitude, place: self.place, account: accountFrom, category: category, transfer: nil) { (transaction) in
                    for tag in self.tags {
                        CoreDataService.instance.saveTag(name: tag, transaction: transaction)
                    }
                    for photo in self.photos {
                        CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transaction)
                    }
                    
                    CoreDataService.instance.saveTransaction(amount: amountWithCurrencyRate.roundTo(places: 2), desc: self.descriptionTxt.text, type: TransactionType.income.rawValue , date: self.date, latitude: self.latitude, longitude: self.longitude, place: self.place, account: accountTo, category: category, transfer: transaction) { (transferTransaction) in
                        for tag in self.tags {
                            CoreDataService.instance.saveTag(name: tag, transaction: transferTransaction)
                        }
                        for photo in self.photos {
                            CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transferTransaction)
                        }
                        self.delegate?.handleTransaction()
                        self.dismissDetail()
                    }
                    
                }
            }
            
        } else {
            CoreDataService.instance.saveTransaction(amount: amount, desc: descriptionTxt.text, type: type, date: date, latitude: latitude, longitude: longitude, place: place, account: accountFrom, category: category, transfer: nil) { (transaction) in
                for tag in tags {
                    CoreDataService.instance.saveTag(name: tag, transaction: transaction)
                }
                for photo in photos {
                    CoreDataService.instance.savePhoto(name: photo.key, image: photo.value, transaction: transaction)
                }
                delegate?.handleTransaction()
                dismissDetail()
            }
        }
    }
    @IBAction func yesterdayBtnPressed(_ sender: Any) {
        yesterdayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
        date = Date() - 86400
    }
    @IBAction func todayBtnPressed(_ sender: Any) {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
        let calendarVC = CalendarVC()
        
        date = Date()
    }
    
    @IBAction func otherDateBtnPressed(_ sender: Any) {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.2915704004, green: 0.2915704004, blue: 0.2915704004, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        
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
    
    
   
    
    
}

extension AddTransactionVC: UITextFieldDelegate, TransactionProtocol, CategoryProtocol, CalendarProtocol {
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
        print(date)
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
        self.view.endEditing(true)
        return true
    }
    
    
}
