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
    @IBOutlet weak var openParentese: UIButton!
    
    @IBOutlet weak var tagsTxt: UITextField!
    
    let height: CGFloat = 40.0
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
    }
    func setUpUIElements(){
        amountTxt.addTarget(self, action: #selector(AddTransactionVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        
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
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func saveTransactionBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
}
