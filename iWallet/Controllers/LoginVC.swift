//
//  LoginVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        usernameTxt.delegate = self
        passwordTxt.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameTxt.text = ""
        passwordTxt.text = ""
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func LoginBtnPressed(_ sender: Any) {
        guard let username = usernameTxt.text else {return}
        LoginHelper.instance.username = username
        LoginHelper.instance.email = username + "@gmail.com"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sw = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
        present(sw, animated: false, completion: nil)
    }
    @IBAction func signUpBtnPressed(_ sender: Any) {
        let signUpVC = SignUpVC()
        signUpVC.modalPresentationStyle = .custom
        presentDetail(signUpVC)
    }
    
}

extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
