//
//  SignUpVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import PKHUD

class SignUpVC: UIViewController {

    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var createBtn: ButtonWithRoundedCorner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        usernameTxt.delegate = self
        emailTxt.delegate = self
        passwordTxt.delegate = self
        createBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        guard let name = usernameTxt.text, let email = emailTxt.text, let password = passwordTxt.text else {return}
        HUD.show(.labeledProgress(title: "Creating account", subtitle: nil))
        LoginService.instance.register(name: name, email: email, password: password) { (auth, message) in
            HUD.hide(animated: true)
            self.showAlert(auth: auth, message: message)
        }
    }
    
    func showAlert(auth: Bool, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: auth ? "Created successfully" : "Create error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                if auth == true {
                    self.dismissDetail()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
