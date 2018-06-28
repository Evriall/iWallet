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
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        emailTxt.delegate = self
        passwordTxt.delegate = self
        signUpBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        CoreDataService.instance.fetchSEProviders { (providers) in
//            for item in providers {
//                print(item.id, item.name, item.secustomer?.id, item.secustomer?.user?.id)
//            }
//        }
//        CoreDataService.instance.fetchSECustomer { (customers) in
//            for item in customers {
//                print(item.id, item.user?.id, item.user?.name)
//            }
//        }
//        CoreDataService.instance.fetchAllCategories { (categories) in
//            for item in categories {
//                print(item.id, item.name, item.systemName, item.user?.id)
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTxt.text = ""
        passwordTxt.text = ""
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func LoginBtnPressed(_ sender: Any) {
        guard let email = emailTxt.text, let password = passwordTxt.text else {return}
        HUD.show(.labeledProgress(title: "Login", subtitle: nil))
        LoginService.instance.getLoginToken(email: email, password: password) { (auth, message, token) in
            if !auth {
                HUD.hide(animated: true)
                self.showAlert(message: message)
                return
            } else {
                LoginService.instance.loginIn(token: token, complition: { (auth, message, id, name, email) in
                    if !auth {
                        HUD.hide(animated: true)
                        self.showAlert(message: message)
                    } else {
                        CoreDataService.instance.fetchUser(ByObjectID: id, complition: { (fetchedUser) in
                            if fetchedUser == nil {
                                CoreDataService.instance.saveUser(id: id, name: name, email: email, complition: { (user) in
                                        guard let user = user else {return}
                                        LoginHelper.instance.currentUser = user.id
                                    UpdateService.instance.fetchData(user: user, complition: { (success) in
                                        if success {
                                            HUD.hide(animated: true)
                                            self.showMainVC()
                                        } else {
                                            HUD.hide(animated: true)
                                            self.showAlert(message: "Can`t initialize data")
                                        }
                                    })
                                })
                            } else {
                                guard let user = fetchedUser, let userID = fetchedUser?.id else {
                                    HUD.hide(animated: true)
                                    self.showAlert(message: "Can`t get userID")
                                    return
                                }
                                if user.name != name || user.email != email {
                                    user.name = name
                                    user.email = email
                                    CoreDataService.instance.update(complition: { (success) in})
                                }
                                LoginHelper.instance.currentUser = userID
                                HUD.hide(animated: true)
                                HUD.show(.labeledProgress(title: "Fetching data", subtitle: nil))
                                UpdateService.instance.fetchData(user: user, complition: { (success) in
                                    CoreDataService.instance.fetchAccounts(userID: userID, complition: { (accounts) in
                                        for item in accounts {
                                            AccountHelper.instance.currentAccount = item.id
                                            HUD.hide(animated: true)
                                            self.showMainVC()
                                            break
                                        }
                                    })
                                })
                                
                            }
                        })
                    }
                })
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
    
    func showAlert(message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Login error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func resetBtnPressed(_ sender: Any) {
        let resetPasswordVC = ResetPasswordVC()
        resetPasswordVC.modalPresentationStyle = .custom
        presentDetail(resetPasswordVC)
    }
    
}

extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
