//
//  SaltEdgeHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 6/1/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import SaltEdge

class SaltEdgeHelper {
    static let instance = SaltEdgeHelper()
    let categoryReplacement = ["business_services":"services",
                               "auto_and_transport":"transport",
                               "bills_and_utilities":"utilities"]
    func fetchSEProvider(id: String, secret: String, customer: SECustomer, complition: @escaping (_ completed: Bool)->()){
        guard let customerID = customer.id else {
            complition(false)
            return
        }
        CoreDataService.instance.fetchSEProvider(ById: id, customerID: customerID) { (providers) in
            if providers.count == 0 {
                SERequestManager.shared.getLogin(with: secret) { (response) in
                    switch response {
                    case .success(let value):
                        CoreDataService.instance.saveSEProvider(name: value.data.providerName, id: id, secret: secret, customer: customer, complition: { (provider) in})
                    case .failure(let error):
                        debugPrint(error.localizedDescription)
                        complition(false)
                    }
                }
            }
        }
    }
    
    func fetchData(){
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchSEProviders(ByUserID: currentUser) { (providers) in
            if providers.count > 0 {
                guard let customerSecret = providers[0].secustomer?.id else {return}
                SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
                SERequestManager.shared.set(customerSecret: customerSecret)
            }
            for (index, item) in providers.enumerated() {
                fetchSEAccounts(provider: item, complition: { success in })
            }
        }
    }
    
    
    func initialFetchData(Provider id: String, ProviderSecret secret: String, customer: SECustomer, complition: @escaping (_ completed: Bool)->()){
        guard let customerID = customer.id else {
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
                        debugPrint(error.localizedDescription)
                        complition(false)
                    }
                }
            } else {
                for (index, item) in providers.enumerated() {
                    fetchSEAccounts(provider: item, complition: { success in
                        if index == providers.count - 1 {
                            complition(success)
                        }
                    })
                }
            }
        }
    }
    
    func fetchSEAccounts(provider: SEProvider, complition: @escaping (_ completed: Bool)->()) {
        guard let secret = provider.secret , let providerName = provider.name, let providerID = provider.id, let user = provider.secustomer?.user, let userID = provider.secustomer?.user?.id else {
            complition(false)
            return
        }
        SERequestManager.shared.getAllAccounts(for: secret, params: nil) { [weak self] response in
            switch response {
            case .success(let value):
                var number = 1
                var status = true
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
                            for account in accounts {
                                var status = true
                                CoreDataService.instance.fetchSETransactionMaxID(account: account, complition: { (fromID) in
                                    self?.fetchSETransactions(providerSecret: secret, account: account, fromTransactionID: fromID, complition: { success in
                                        if !success {
                                            status = false
                                        }
                                        if index == value.data.count - 1 {
                                            complition(status)
                                        }
                                    })
                                })
                                
                            }
                            if index == value.data.count - 1 {
                                complition(true)
                            }
                        }
                    })
                    
                }
            case .failure(let error):
                debugPrint(error.localizedDescription)
                complition(false)
            }
        }
    }
    
    func fetchCategories(user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
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
                debugPrint(error.localizedDescription)
                complition(false)
            }
        })
    }
    
    func fetchSETransactions(providerSecret: String, account: Account, fromTransactionID: String? = nil, complition: @escaping (_ completed: Bool)->()){
        guard let user = account.user, let userID = account.user?.id else {
            complition(false)
            return
        }
        
        let params = SETransactionParams(accountId: account.se_id, fromId: fromTransactionID)
//        SERequestManager.shared.getAllTransactions(for: providerSecret) { [weak self] response in
        SERequestManager.shared.getAllTransactions(for: providerSecret, params: params) { [weak self] response in
            switch response {
            case .success(let value):
                for (index, item) in value.data.enumerated() {
                    CoreDataService.instance.fetchTransactions(account: account, se_id: item.id, complition: { (transactions) in
                        if transactions.count == 0 {
                            CoreDataService.instance.fetchCategory(ByName: item.category, system: true, userID: userID, complition: { (categories) in
                                if categories.count == 0 {
                                    self?.fetchCategories(user: user, complition: { (success) in
                                        if success {
                                            CoreDataService.instance.fetchCategory(ByName: item.category, system: true, userID: userID, complition: { (categories) in
                                                if categories.count == 0 {
                                                    CoreDataService.instance.fetchCategory(ByName: Constants.CATEGORY_UNCATEGORIZED, system: true, userID: userID, complition: { (uncategorizedCategories) in
                                                        for category in uncategorizedCategories {
                                                            CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, se_id: item.id, complition: { (transaction) in
                                                                if index == value.data.count - 1 {
                                                                    complition(true)
                                                                }
                                                            })
                                                        }
                                                    })
                                                } else {
                                                    for (categoryIndex, category) in categories.enumerated() {
                                                        CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, se_id: item.id, complition: { (transaction) in
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
                                        CoreDataService.instance.saveTransaction(amount: fabs(item.amount.roundTo(places: 2)), desc: item.description, type: item.amount > 0 ? TransactionType.income.rawValue : TransactionType.costs.rawValue, date: item.createdAt, place: nil, account: account, category: category, transfer: nil, se_id: item.id, complition: { (transaction) in
                                            if index == value.data.count - 1 && categoryIndex == categories.count - 1 {
                                                complition(true)
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    })
                }
            case .failure(let error):
                complition(false)
                debugPrint(error.localizedDescription)
            }
        }
    }
    
}