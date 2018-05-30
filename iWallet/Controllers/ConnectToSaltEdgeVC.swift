//
//  ConnectToSaltEdgeVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import WebKit
import SaltEdge
import PKHUD
import Alamofire

class ConnectToSaltEdgeVC: UIViewController {
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var webView: SEWebView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    private var providers: [(name : String, id: String, countryCode: String)] = []
    private var filteredProviders: [(name : String, id: String, countryCode: String)] = []
    private let searchController = UISearchController(searchResultsController: nil)
    let categoryReplacement = ["business_services":"services",
                               "auto_and_transport":"transport",
                               "bills_and_utilities":"utilities"]
    private var customer: SECustomer?
    private var secret: String = ""
    private var loginID: String = ""
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.stateDelegate = self
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchUser(ByObjectID: currentUser) { (user) in
            guard let user = user else {
                continueBtn.isHidden = true
                return
            }
            self.user = user
        }
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    
    func requestToken() {
        HUD.show(.labeledProgress(title: "Requesting Token", subtitle: nil))
            // Set javascriptCallbackType to "iframe" to receive callback with login_id and login_secret
            // see https://docs.saltedge.com/guides/connect
            let tokenParams = SECreateTokenParams(fetchScopes: ["accounts", "transactions"], returnTo: "http://httpbin.org", javascriptCallbackType: "iframe")
            // Check if SERequestManager will call handleTokenResponse
            SERequestManager.shared.createToken(params: tokenParams) { [weak self] response in
                self?.handleTokenResponse(response)
            }
    }
    
    private func handleTokenResponse(_ response: SEResult<SEResponse<SETokenResponse>>) {
        switch response {
        case .success(let value):
            HUD.hide(animated: true)
            if let url = URL(string: value.data.connectUrl) {
                let request = URLRequest(url: url)
                webView.load(request)
                webView.isHidden = false
            }
        case .failure(let error):
            HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
        }
    }
    
    func showAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "There are no internet connection", message: "Can`t connect to server", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.dismissDetail()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func continueBtnPressed(_ sender: Any) {
        if !NetworkReachabilityManager()!.isReachable {
            self.showAlert()
            return
        }
        infoLbl.isHidden = true
        webView.isHidden = false
        
        guard let user = user else {return}
            if let customer = user.se_customer, let secret = user.se_customer?.id {
                self.customer = customer
                SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
                SERequestManager.shared.set(customerSecret: secret)
                requestToken()
            } else {
                if let email = user.email {
                    SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
                    let params = SECustomerParams(identifier: email)
                    SERequestManager.shared.createCustomer(with: params) { response in
                        switch response {
                        case .success(let value):
                            CoreDataService.instance.saveSECustomer(id: value.data.secret, user: user, complition: { (customer) in
                                if let customer = customer {
                                    self.customer = customer
                                    SERequestManager.shared.set(customerSecret: value.data.secret)
                                    self.requestToken()
                                }
                            })
                        case .failure(let error): print(error)
                        }
                    }
                }
            }
    }
    func fetchSEAccounts(provider: SEProvider, complition: @escaping (_ completed: Bool)->()) {
        guard let secret = provider.secret , let providerName = provider.name, let providerID = provider.id, let user = user, let userID = user.id else {
            complition(false)
            return
        }
        SERequestManager.shared.getAllAccounts(for: secret, params: nil) { [weak self] response in
            switch response {
            case .success(let value):
                var number = 1
                for (index, item) in value.data.enumerated() {
                    CoreDataService.instance.fetchAccount(bySE_ID: item.id, seProviderID: providerID, userID: userID, complition: { (accounts) in
                        if accounts.count == 0 {
                            var accountName = providerName
                            if let cards = item.extra?.cards {
                                for card in cards {
                                    if card.count >= 4 {
                                        accountName += " \(card[(card.count - 4)..<card.count])"
                                        break
                                    } else {
                                        continue
                                    }
                                }
                            }
                            if accountName == providerName {
                                accountName += " \(number)"
                                number += 1
                            }
                                CoreDataService.instance.saveSEAccount(name: accountName, type: AccountType.DebitCard.rawValue, currency: item.currencyCode, external: false, seID: item.id, seProvider: provider, user: user, complition: { (account) in
                                    if let account = account {
                                        var status = true
                                        self?.fetchSETransactions(providerSecret: secret, account: account, complition: { success in
                                            if !success {
                                                status = false
                                            }
                                            if index == value.data.count - 1 {
                                                complition(status)
                                            }
                                        })
                                    } else {
                                        if index == value.data.count - 1 {
                                            complition(false)
                                        }
                                    }
                                })
                        } else {
                            if index == value.data.count - 1 {
                                complition(true)
                            }
                        }
                    })
                    
                }
                HUD.hide(animated: true)
            case .failure(let error):
                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
                complition(false)
            }
        }
    }
    
    func fetchCategories(complition: @escaping (Bool)->()){
        guard let user = user, let userID = user.id else {
            complition(false)
            return
        }
        SERequestManager.shared.getCategories(completion: { (responseCategories) in
            switch responseCategories {
            case .success(let value):
                var index = 0
                for (key, childArray) in value.data {
                    let key  = self.categoryReplacement[key] ?? key
                    CoreDataService.instance.fetchCategoryParent(ByName: key, system: true, userID: userID, complition: { (categories) in
                        if categories.count == 0 {
                            CoreDataService.instance.saveCategory(name: key.replacingOccurrences(of: "_", with: "  "), color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), parent: nil,systemName: key, user: user, complition: { (parent) in
                                if parent != nil {
                                    if childArray.count == 0 {
                                        if index == value.data.count - 1 {
                                            complition(true)
                                        }
                                    } else {
                                        for (indexChild, child) in childArray.enumerated() {
                                            CoreDataService.instance.saveCategory(name: child.replacingOccurrences(of: "_", with: "  "), color:  #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), parent: parent, user: user, complition: { (category) in
                                                if index == value.data.count - 1 && indexChild == childArray.count - 1{
                                                    complition(true)
                                                }
                                            })
                                        }
                                    }
                                } else {
                                    if index == value.data.count - 1 {
                                        complition(true)
                                    }
                                }
                            })
                        } else {
                            for parent in categories {
                                if childArray.count == 0 {
                                    if index == value.data.count - 1 {
                                        complition(true)
                                    }
                                } else {
                                    for (indexChild, child) in childArray.enumerated() {
                                        CoreDataService.instance.fetchCategory(ByName: child, system: true, userID: userID, complition: { (childCategories) in
                                            if childCategories.count == 0 {
                                                CoreDataService.instance.saveCategory(name: child.replacingOccurrences(of: "_", with: "  "), color:  #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), parent: parent, user: user, complition: { (category) in
                                                    if index == value.data.count - 1 && indexChild == childArray.count - 1{
                                                        complition(true)
                                                    }
                                                })
                                            } else {
                                                if index == value.data.count - 1 && indexChild == childArray.count - 1{
                                                    complition(true)
                                                }
                                            }
                                        })
                                       
                                    }
                                }
                            }
                        }
                    })
                    
                    index += 1
                }
                
            case .failure(let error):
                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
                complition(false)
            }
        })
    }
    
    func fetchSETransactions(providerSecret: String, account: Account, complition: @escaping (_ completed: Bool)->()){
        guard let userID = user?.id else {
            complition(false)
            return
        }
        HUD.show(.labeledProgress(title: "Fetching Transactions", subtitle: nil))
        let params = SETransactionParams(accountId: account.se_id)
        SERequestManager.shared.getAllTransactions(for: providerSecret) { [weak self] response in
//        SERequestManager.shared.getAllTransactions(for: providerSecret, params: params) { [weak self] response in
            switch response {
            case .success(let value):
                for (index, item) in value.data.enumerated() {
                    CoreDataService.instance.fetchCategory(ByName: item.category, system: true, userID: userID, complition: { (categories) in
                        if categories.count == 0 {
                            self?.fetchCategories(complition: { (success) in
                                if success {
                                    CoreDataService.instance.fetchCategory(ByName: item.category, system: true, userID: userID, complition: { (categories) in
                                        if categories.count == 0 {
                                            CoreDataService.instance.fetchCategory(ByName: Constants.CATEGORY_UNCATEGORIZED, system: true, userID: userID, complition: { (uncategorizedCategories) in
                                                for category in uncategorizedCategories {
                                                    CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, complition: { (transaction) in
                                                        if index == value.data.count - 1 {
                                                            complition(true)
                                                        }
                                                    })
                                                }
                                            })
                                        } else {
                                            for (categoryIndex, category) in categories.enumerated() {
                                                CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, complition: { (transaction) in
                                                    if index == value.data.count - 1 && categoryIndex == categories.count - 1 {
                                                        complition(true)
                                                    }
                                                })
                                            }
                                        }
                                    })
                                }
                            })
                        } else {
                            for (categoryIndex, category) in categories.enumerated() {
                             CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, complition: { (transaction) in
                                if index == value.data.count - 1 && categoryIndex == categories.count - 1 {
                                    complition(true)
                                }
                             })
                            }
                        }
                    })
                   
                }
                HUD.hide(animated: true)
            case .failure(let error):
                complition(false)
                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
            }
        }
    }
    
    func fetchRegisteredProviders(id: String, secret: String, complition: @escaping (_ completed: Bool)->()){
        guard let customer = self.customer, let customerID = self.customer?.id else {
            complition(false)
            return
        }
                CoreDataService.instance.fetchSEProvider(ById: id, customerID: customerID) { (providers) in
                    if providers.count == 0 {
                        SERequestManager.shared.getLogin(with: secret) { (response) in
                            switch response {
                            case .success(let value):
                                CoreDataService.instance.saveSEProvider(name: value.data.providerName, id: id, secret: secret, customer: customer, complition: { (provider) in
                                    if let provider = provider {
                                        self.fetchSEAccounts(provider: provider, complition: { success in
                                            if success {
                                                complition(true)
                                            } else {
                                                complition(false)
                                            }
                                        })
                                    }
                                })
                            case .failure(let error):
                                HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
                                complition(false)
                            }
                        }
                    } else {
                        for (index, item) in providers.enumerated() {
                            if item.secret != secret {
                                item.secret = secret
                                CoreDataService.instance.update(complition: { (success) in
                                    if success {
                                        fetchSEAccounts(provider: item, complition: { success in
                                            if index == providers.count - 1 {
                                                complition(success)
                                            }
                                        })
                                    }
                                })
                            } else {
                                fetchSEAccounts(provider: item, complition: { success in
                                    if index == providers.count - 1 {
                                        complition(success)
                                    }
                                })
                            }
                        }
                    }
                }
    }
}

extension ConnectToSaltEdgeVC: SEWebViewDelegate {

    func webView(_ webView: SEWebView, didReceiveCallbackWithResponse response: SEConnectResponse) {
        switch response.stage {
        case .success:
            print("Fetched successfully")
//            let mainVC = MainVC()
//            mainVC.modalPresentationStyle = .custom
//            presentDetail(mainVC)
            if !self.secret.isEmpty && !self.loginID.isEmpty {
                fetchRegisteredProviders(id: self.loginID, secret: self.secret, complition: { success in
                    if success {
                        DispatchQueue.main.async {
                            HUD.flash(.labeledSuccess(title: "Finished loading data", subtitle: ""), delay: 2.0)
                        }
                    } else {
                         DispatchQueue.main.async {
                            HUD.flash(.labeledError(title: "Data loaded with errors", subtitle: ""), delay: 2.0)
                        }
                    }
                })
            }
        case .fetching:
            if let secret = response.secret, let id = response.loginId {
                self.secret = secret
                self.loginID = id
//                closeBtn.isEnabled = false
            }
        case .error:
            HUD.flash(.labeledError(title: "Cannot Fetch Login", subtitle: nil), delay: 3.0)
        }
    }
    
    func webView(_ webView: SEWebView, didReceiveCallbackWithError error: Error) {
        HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
    }
}

