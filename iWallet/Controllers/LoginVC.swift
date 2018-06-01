//
//  LoginVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import SaltEdge
import PKHUD

class LoginVC: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        email.delegate = self
        passwordTxt.delegate = self
        signUpBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        email.text = ""
        passwordTxt.text = ""
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func LoginBtnPressed(_ sender: Any) {
        guard let email = email.text else {return}
        CoreDataService.instance.fetchUser(ByEmail: email) { (users) in
            if users.count == 0 {
                CoreDataService.instance.saveUser(name: "Test", email: email, complition: { (user) in
                    guard let user = user else {return}
                    LoginHelper.instance.currentUser = user.id
                    InitDataHelper.instance.checkInitData(complition: { (success) in
                        if success {
                            self.showMainVC()
                        } else {
                            HUD.flash(.labeledError(title: "Error", subtitle: "Can`t initialize data"), delay: 3.0)
                        }
                    })
                })
            } else {
                for user in users {
                    LoginHelper.instance.currentUser = user.id
                    showMainVC()
                    break
                }
            }
        }
    }
    
    func showMainVC(){
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
