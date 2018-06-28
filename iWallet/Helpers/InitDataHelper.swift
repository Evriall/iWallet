//
//  InitDataHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/6/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class InitDataHelper {
    static let instance = InitDataHelper()
    
//    func checkInitData(complition: @escaping (Bool)->()){
//        guard let currentUser = LoginHelper.instance.currentUser else {return}
//        CoreDataService.instance.fetchCategoryParents(userID: currentUser) { (categories) in
//            if categories.count == 0 {
//                CategoryHelper.instance.initCategories(userID: currentUser, complition: { (success) in
//                    if success {
//                        CoreDataService.instance.fetchAccounts(userID: currentUser) { (accounts) in
//                            if accounts.count == 0 {
//                                AccountHelper.instance.initExternalAccount(complition: { (success) in
//                                    if success {
//                                        AccountHelper.instance.initPersonalAccount({ (success) in
//                                            if success {
//                                                CoreDataService.instance.fetchAccounts(userID: currentUser, complition: { (accounts) in
//                                                    for item in accounts {
//                                                        AccountHelper.instance.currentAccount = item.id
//                                                        complition(true)
//                                                        break
//                                                    }
//                                                })
//                                            } else {
//                                                complition(false)
//                                            }
//                                        })
//                                    } else {
//                                        complition(false)
//                                    }
//                                })
//                            }
//                        }
//                    } else {
//                        complition(false)
//                    }
//                })
//            } else {
//                complition(true)
//            }
//        }
//        
//        
//    }
}
