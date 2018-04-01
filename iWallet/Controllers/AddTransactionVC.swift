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
    
    @IBOutlet weak var descriptionTxt: UITextField!
    @IBOutlet weak var typeBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryBtn: ButtonWithRightImage!
    @IBOutlet weak var categoryImg: UIImageView!
    
    @IBOutlet weak var tagsTxt: UITextField!
    
    @IBOutlet weak var yesterdayBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var otherDateBtn: UIButton!
    
    let height: CGFloat = 40.0
    var category: Category?
    var date = Date()
    
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
        
        typeBtn.setTitle(TransactionHelper.instance.currentType, for: .normal)
        
        categoryBtn.titleLabel?.numberOfLines = 0
        categoryBtn.titleLabel?.lineBreakMode = .byWordWrapping
        
        if let currentCategory = CategoryHelper.instance.currentCAtegory {
            CoreDataService.instance.fetchCategory(ByObjectID: currentCategory) { (categoryFetched) in
                self.category = categoryFetched
                categoryBtn.setTitle(textNameCategory(category: categoryFetched), for: .normal)
                categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: categoryFetched.color)
            }
        } else {
            CoreDataService.instance.fetchCategory(ByName: "Without category", complition: { (categories) in
                for item in categories {
                    self.category = item
                    categoryBtn.setTitle(item.name, for: .normal)
                    categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: item.color)
                }
            })
        }
      yesterdayBtn.setImage(nil, for: .normal)
      otherDateBtn.setImage(nil, for: .normal)
    }
    func textNameCategory(category: Category?) -> String{
        guard let category = category else {
            return ""
        }
        guard let name = category.name else {return ""}
        guard let parentName = category.parent?.name else {return name}
        return "\(parentName)\n\(name)"
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
        CategoryHelper.instance.currentCAtegory = category?.objectID.uriRepresentation().absoluteString
        dismissDetail()
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
    
    func formatDateToStr(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: date)
    }
}

extension AddTransactionVC: UITextFieldDelegate, TransactionProtocol, CategoryProtocol, CalendarProtocol {
    func handleDate(_ date: Date) {
        self.date = date
        otherDateBtn.setTitle(formatDateToStr(date: date), for: .normal)
        print(date)
    }
    
    func handleTransactionType(_ type: String) {
        typeBtn.setTitle(type, for: .normal)
        TransactionHelper.instance.currentType = type
    }
    
    func handleCategory(_ category: Category) {
        self.category = category
        categoryBtn.setTitle(textNameCategory(category: category), for: .normal)
        categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: category.color)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
}
