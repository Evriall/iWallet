//
//  RessetPasswordVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 6/10/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import PKHUD

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        //        emailTxt.delegate = self
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        guard let email = emailTxt.text else {return}
        HUD.show(.labeledProgress(title: "Reseting password", subtitle: nil))
        LoginService.instance.resetPassword(email: email) { (auth, message) in
            HUD.hide(animated: true)
            self.showAlert(auth: auth, message: message)
        }
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
    func showAlert(auth: Bool, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: auth ? "Reset" : "Reset error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                if auth == true {
                    self.dismissDetail()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ResetPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
