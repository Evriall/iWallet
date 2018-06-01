//
//  AddAccountVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit


class AddAccountVC: UIViewController {
    
    @IBOutlet weak var typeAccountBtn: ButtonWithRightImage!
    @IBOutlet weak var nameAccountTxt: UITextField!
    @IBOutlet weak var currencyAccountBtn: ButtonWithRightImage!
    @IBOutlet weak var saveAccountBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    
    var account: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    func setUIElements(){
        nameAccountTxt.delegate = self
        nameAccountTxt.addTarget(self, action: #selector(AddAccountVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        if let account = self.account {
            saveAccountBtn.isEnabled = true
            nameAccountTxt.text = account.name
            typeAccountBtn.setTitle(account.type, for: .normal)
            currencyAccountBtn.setTitle(account.currency, for: .normal)
            backBtn.setImage(UIImage(named: "CloseRoundedDarkIcon"), for: .normal)
        }else {
            saveAccountBtn.isEnabled = false
            typeAccountBtn.setTitle(AccountType.Cash.rawValue, for: .normal)
            currencyAccountBtn.setTitle(AccountHelper.instance.getLocaleCarrencySymbolAndCode().code, for: .normal)
            return
        }
    }
    @objc func textFieldDidChange(){
        guard let text = nameAccountTxt.text else {return}
        if text.isEmpty {
            saveAccountBtn.isEnabled = false
        } else {
            saveAccountBtn.isEnabled = true
        }
        
    }
    @IBAction func currencyAccountBtnPressed(_ sender: Any) {
        let selectAccountCurrencyVC = SelectCurrencyVC()
        selectAccountCurrencyVC .delegate = self
        selectAccountCurrencyVC .modalPresentationStyle = .custom
        presentDetail(selectAccountCurrencyVC )
    }
    
    @IBAction func typeAccountBtnPressed(_ sender: Any) {
        let selectTypeAccountVC = SelectAccountTypeVC()
        selectTypeAccountVC.delegate = self
        selectTypeAccountVC.modalPresentationStyle = .custom
        presentDetail(selectTypeAccountVC)
    }
    @IBAction func saveAccountBtnPressed(_ sender: Any) {
        guard let name = nameAccountTxt.text, !name.isEmpty else {return}
        guard let type = typeAccountBtn.titleLabel?.text else {return}
        guard let currency = currencyAccountBtn.titleLabel?.text else {return}
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchUser(ByObjectID: currentUser) { (user) in
            guard let user = user else {return}
            CoreDataService.instance.saveAccount(name: name, type: type, currency: currency, user: user) { (success) in
                if success {
                    self.dismissDetail()
                }
            }
        }
    }

    
}

extension AddAccountVC: UITextFieldDelegate, AccountProtocol {
    func handleCurrency(_ currency: String, currencyRate: Double) {
        currencyAccountBtn.setTitle(currency, for: .normal)
    }

    
    func handleAccountType(_ type: String) {
        typeAccountBtn.setTitle(type, for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
