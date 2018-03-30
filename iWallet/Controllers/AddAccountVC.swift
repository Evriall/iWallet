//
//  AddAccountVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/29/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddAccountVC: UIViewController {
    
    @IBOutlet weak var typeAccountBtn: ButtonWithImage!
    @IBOutlet weak var nameAccountTxt: UITextField!
    @IBOutlet weak var currencyAccountBtn: ButtonWithImage!
    @IBOutlet weak var saveAccountBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    func setUIElements(){
        saveAccountBtn.bindToKeyBoard()
        saveAccountBtn.isEnabled = false
        saveAccountBtn.setDeselectedColor()
        nameAccountTxt.delegate = self
        nameAccountTxt.addTarget(self, action: #selector(AddAccountVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        typeAccountBtn.setTitle(AccountType.Cash.rawValue, for: .normal)
        currencyAccountBtn.setTitle(AccountHelper.instance.getLocaleCarrencySymbolAndCode().code, for: .normal)
    }
    @objc func textFieldDidChange(){
        guard let text = nameAccountTxt.text else {return}
        if text.isEmpty {
            saveAccountBtn.isEnabled = false
            saveAccountBtn.setDeselectedColor()
        } else {
            saveAccountBtn.isEnabled = true
            saveAccountBtn.setSelectedColor()
        }
        
    }
    @IBAction func currencyAccountBtnPressed(_ sender: Any) {
        let selectAccountCurrencyVC = SelectAccountCurrencyVC()
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
    }
}

extension AddAccountVC: UITextFieldDelegate, AccountProtocol {
    func handleCarrency(_ currency: String) {
        currencyAccountBtn.setTitle(currency, for: .normal)
    }
    
    func handleType(_ type: String) {
        typeAccountBtn.setTitle(type, for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
