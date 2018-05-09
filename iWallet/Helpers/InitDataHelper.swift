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
    
    func checkInitData(){
        CoreDataService.instance.fetchCategoryParents { (categories) in
            if categories.count == 0 {
                CategoryHelper.instance.initCategories()
            }
        }
        CoreDataService.instance.fetchAccounts { (accounts) in
            if accounts.count == 0 {
                AccountHelper.instance.initExternalAccount()
                AccountHelper.instance.initPersonalAccount({ (success) in
                    if success {
                        CoreDataService.instance.fetchAccounts(complition: { (accounts) in
                            for item in accounts {
                                AccountHelper.instance.currentAccount = item.id
                            }
                        })
                    }
                })
            }
            
        }
    }
}
