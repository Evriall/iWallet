//
//  UpdateService.swift
//  iWallet
//
//  Created by Sergey Guznin on 6/15/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UpdateService {
    static let instance = UpdateService()
    
    func uploadData(user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else{
            complition(false)
            return
        }
        let lastUpload = user.lastUpload ?? Date(timeIntervalSince1970: 0.0)
        let newUpload = Date()
        UpdateHelper.instance.formLastDataToUpload(userID: userID, lastUpload: lastUpload) { (data) in
            if data.count == 0 {
                complition(true)
            } else {
                var headers = Constants.HEADER_REGISTER
                headers["id"] = userID

                    Alamofire.request("\(Constants.URL_LOGIN)/api/update", method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                        if response.result.error == nil {
                            guard let data = response.data else {
                                complition(false)
                                return
                            }
                            let json = JSON(data)
                            if let auth = json["auth"].bool, let message = json["message"].string{
                                if !auth {
                                    complition(false)
                                } else {
                                    user.lastUpload = newUpload
                                    CoreDataService.instance.update(complition: { (success) in
                                        complition(success)
                                    })
                                }
                            } else {
                                complition(false)
                            }
                        } else {
                            debugPrint(response.result.error as Any)
                            complition(false)
                        }
                    }
            }
        }
    }
    
    func fetchData(user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else{
            complition(false)
            return
        }
        let lastFetch = user.lastFetch ?? "1970-01-01T00:00:00.000Z"
        var headers = Constants.HEADER_REGISTER
        headers["id"] = userID
        headers["date"] = lastFetch
        Alamofire.request("\(Constants.URL_LOGIN)/api/update", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {
                    complition(false)
                    return
                }
                let json = JSON(data)
                if let categories = json["categories"].array, let accounts = json["accounts"].array, let seCustomers = json["seCustomers"].array, let seProviders = json["seProviders"].array, let transactions = json["transactions"].array, let places = json["places"].array, let date = json["date"].string{
                    UpdateHelper.instance.saveSECustomers(seCustomers: seCustomers, user: user, complition: { (success) in
                        if success {
                            UpdateHelper.instance.saveSEProviders(seProviders: seProviders, user: user, complition: { (success) in
                                if success {
                                    UpdateHelper.instance.saveCategories(categories: categories, user: user, complition: { (success) in
                                        if success {
                                            UpdateHelper.instance.saveAccounts(accounts: accounts, user: user, complition: { (success) in
                                                if success {
                                                    UpdateHelper.instance.savePlaces(places: places, complition: { (success) in
                                                        if success {
                                                            UpdateHelper.instance.saveTransactions(transactions: transactions, user: user, complition: { (success) in
                                                                if success {
                                                                    user.lastFetch = date
                                                                    CoreDataService.instance.update(complition: { (success) in
                                                                        complition(success)
                                                                    })
                                                                } else {
                                                                    complition(false)
                                                                }
                                                            })
                                                        } else {
                                                            complition(false)
                                                        }
                                                    })
                                                    
                                                } else {
                                                    complition(false)
                                                }
                                            })
                                        } else {
                                            complition(false)
                                        }
                                    })
                                } else {
                                    complition(false)
                                }
                            })
                        } else {
                            complition(false)
                        }
                    })   
                } else {
                    complition(false)
                }
            } else {
                debugPrint(response.result.error as Any)
                complition(false)
            }
        }
    }
}
