//
//  UpdateHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 6/15/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import SwiftyJSON

class UpdateHelper {
    struct CategoryWrapper {
        let name: String
        let systemName: String
        let color: String
        let id: String
        let parent: String
    }
    static let instance = UpdateHelper()
    
    func formLastDataToUpload(userID: String, lastUpload: Date, complition: @escaping ([String : Any])->()){
        var uploadData  = [String : Any]()
        CoreDataService.instance.fetchLastSECustomer(ByDate: lastUpload, userID: userID) { (seCustomer) in
            if seCustomer != nil {
                if let id = seCustomer?.id {
                    uploadData["seCustomers"] = [["seid": id]]
                }
            }
            CoreDataService.instance.fetchLastSEProviders(ByDate: lastUpload, userID: userID, complition: { (seProviders) in
                if seProviders.count > 0 {
                    var convertedSEProviders  = [[String:String]]()
                    for item in seProviders {
                        guard let id = item.id, let name = item.name, let secret = item.secret, let seCustomerID = item.secustomer?.id else {continue}
                        convertedSEProviders.append(["seid" : id, "name" : name, "secret" : secret, "seCustomer" : seCustomerID])
                    }
                    uploadData["seProviders"] = convertedSEProviders
                }
                CoreDataService.instance.fetchLastCategories(ByDate: lastUpload, userID: userID, complition: { (categories) in
                    if categories.count > 0 {
                        var convertedCategories  = [[String:String]]()
                        for item in categories {
                            guard let id = item.id, let name = item.name, let systemName = item.systemName, let color = item.color else {continue}
                            if let parent = item.parent?.id {
                                convertedCategories.append(["mobAppId" : id, "name" : name, "systemName" : systemName, "color" : color, "parent" : parent])
                            } else {
                                convertedCategories.append(["mobAppId" : id, "name" : name, "systemName" : systemName, "color" : color])
                            }
                        }
                        uploadData["categories"] = convertedCategories
                    }
                    CoreDataService.instance.fetchLastAccounts(ByDate: lastUpload, userID: userID, complition: { (accounts) in
                        if accounts.count > 0 {
                            var convertedAccounts  = [[String : Any]]()
                            for item in accounts {
                                guard let id = item.id, let name = item.name, let systemName = item.systemName, let type = item.type, let currency = item.currency else {continue}
                                if let seid = item.se_id, let seProvider = item.se_provider?.id {
                                    convertedAccounts.append(["mobAppId" : id, "name" : name, "systemName" : systemName, "type" : type, "currency" : currency, "external" : item.external, "seid" : seid, "seProvider" : seProvider])
                                } else {
                                    convertedAccounts.append(["mobAppId" : id, "name" : name, "systemName" : systemName, "type" : type, "currency" : currency, "external" : item.external])
                                }
                            }
                            uploadData["accounts"] = convertedAccounts
                        }
                        CoreDataService.instance.fetchLastTransactions(ByDate: lastUpload, userID: userID, complition: { (transactions) in
                            if transactions.count == 0 {
                                if seCustomer == nil && seProviders.count == 0 && categories.count == 0 && accounts.count == 0 {
                                    uploadData = [ : ]
                                }
                                complition(uploadData)
                            } else {
                                var convertedTransactions  = [[String : Any]]()
                                var places = [String]()
                                for (index, item) in transactions.enumerated() {
                                    guard let mobAppId = item.id, let seid = item.se_id, let date = item.date?.updateServerStr(), let type = item.type, let category = item.category?.id, let account = item.account?.id else {
                                            if index == transactions.count - 1 {
                                                complition(uploadData)
                                            }
                                            continue
                                        }
                                    
                                    var convertedTags = [String]()
                                    CoreDataService.instance.fetchTags(transaction: item, complition: { (tags) in
                                        for tag in tags {
                                            guard let name = tag.name else {continue}
                                            convertedTags.append(name)
                                        }
                                        var convertedTransaction : [String : Any] = ["mobAppId" : mobAppId, "type" : type, "date" : date, "category" : category, "account" : account, "tags" : convertedTags, "amount" : item.amount]
                                        if !seid.isEmpty {
                                            convertedTransaction["seid"] = seid
                                        }
                                        if let transfer = item.transfer?.id {
                                            convertedTransaction["transfer"] = transfer
                                        }
                                        if let place = item.place?.id {
                                            convertedTransaction["place"] = place
                                            places.append(place)
                                        }
                                        if let desc = item.desc {
                                            convertedTransaction["desc"] = desc
                                        }
                                        convertedTransactions.append(convertedTransaction)
                                        if index == transactions.count - 1 {
                                            uploadData["transactions"] = convertedTransactions
                                            if places.count == 0 {
                                                complition(uploadData)
                                            } else {
                                                CoreDataService.instance.fetchPlacesByIds(ids: places, complition: { (fetchedPlaces) in
                                                    if fetchedPlaces.count == 0 {
                                                        complition(uploadData)
                                                    } else {
                                                        var convertedPlaces = [[String: Any]]()
                                                        for fetchedPlace in fetchedPlaces {
                                                            guard let name = fetchedPlace.name, let id = fetchedPlace.id, let address = fetchedPlace.address else {
                                                                    continue
                                                                }
                                                            convertedPlaces.append(["fsid" : id, "name" : name, "address" : address, "latitude" : fetchedPlace.latitude, "longitude" : fetchedPlace.longitude])
                                                        }
                                                        uploadData["places"] = convertedPlaces
                                                        complition(uploadData)
                                                    }
                                                })
                                            }
                                        }
                                    })
                                }
                            }
                        })
                        
                    })
                })
            })
        }
    }
    
    func saveTags(transaction: Transaction, tags:[String], complition: @escaping (Bool)->()){
        CoreDataService.instance.fetchTags(transaction: transaction) { (fetchedTags) in
            if fetchedTags.count == 0 {
                for item in tags {
                    CoreDataService.instance.saveTag(name: item, transaction: transaction)
                }
                complition(true)
            } else {
                for item in fetchedTags {
                    if let name = item.name {
                        if tags.contains(name) {
                            continue
                        } else {
                            CoreDataService.instance.removeTag(tag: item)
                        }
                    } else {
                        CoreDataService.instance.removeTag(tag: item)
                    }
                }
                for item in tags {
                    var equal = false
                    for fethedItem in fetchedTags {
                        if let name = fethedItem.name {
                            if item == name { equal = true}
                            break
                        } else {
                            CoreDataService.instance.removeTag(tag: fethedItem)
                        }
                    }
                    if !equal {
                        CoreDataService.instance.saveTag(name: item, transaction: transaction)
                    }
                }
                complition(true)
            }
        }
    }
    
    func saveTransactions(transactions: [JSON], user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
            complition(false)
            return
        }
        if transactions.count == 0 {
            complition(true)
        } else {
            var result = true
            for (index, item) in transactions.enumerated() {
                if let transaction = item.dictionary {
                    if let id = transaction["mobAppId"]?.string, let amount = transaction["amount"]?.double, let dateStr = transaction["date"]?.string, let type = transaction["type"]?.string, let accountID = transaction["account"]?.string, let categoryID = transaction["category"]?.string {
                        guard let date = dateStr.updateServerDate() else {
                            complition(false)
                            return
                        }
                        var tags = [String]()
                        if let jsonTags = transaction["tags"]?.array {
                            for jsonTag in jsonTags {
                                if let tag = jsonTag.string {
                                    tags.append(tag)
                                }
                            }
                        }
                        let seid = transaction["seid"]?.string ?? ""
                        let placeID = transaction["place"]?.string
                        let desc = transaction["desc"]?.string
                        
                        if placeID != nil {
                            CoreDataService.instance.fetchPlaceById(id: placeID!) { (places) in
                                if places.count == 0 {
                                    result = false
                                    if index == transactions.count - 1 {
                                        complition(result)
                                    }
                                } else {
                                    for place in places {
                                        CoreDataService.instance.fetchAccount(ByObjectID: accountID, userID: userID, complition: { (account) in
                                            if account == nil {
                                                complition(false)
                                                return
                                            } else {
                                                CoreDataService.instance.fetchCategory(ByObjectID: categoryID, userID: userID, complition: { (category) in
                                                    if category == nil {
                                                        complition(false)
                                                        return
                                                    } else {
                                                        if let transfer = transaction["transfer"]?.string {
                                                                CoreDataService.instance.fetchTransaction(ById: transfer, withSEId: seid, account: account!, complition:
                                                                    { (transferTransaction) in
                                                                    if transferTransaction != nil {
                                                                         CoreDataService.instance.fetchTransaction(ById: id, withSEId: seid, account: account!, complition: { (fetchedTransaction) in
                                                                            if fetchedTransaction == nil {
                                                                                CoreDataService.instance.saveTransaction(amount: amount, desc: desc, type: type, date: date, place: place, account: account!, category: category!, transfer: fetchedTransaction, se_id: seid, id: id, complition: { (savedTransaction) in
                                                                                        if tags.count == 0 {
                                                                                            if index == transactions.count - 1 {
                                                                                                complition(result)
                                                                                            }
                                                                                        } else {
                                                                                            for tag in tags {
                                                                                                CoreDataService.instance.saveTag(name: tag, transaction: savedTransaction)
                                                                                            }
                                                                                            if index == transactions.count - 1 {
                                                                                                complition(result)
                                                                                            }
                                                                                        }
                                                                                })
                                                                            } else {
                                                                                self.saveTags(transaction: fetchedTransaction!, tags: tags, complition: { (success) in
                                                                                    if fetchedTransaction!.amount != amount || fetchedTransaction!.category != category || fetchedTransaction!.place != place || fetchedTransaction!.date != date || fetchedTransaction!.type != type || fetchedTransaction!.desc != desc {
                                                                                        fetchedTransaction?.amount = amount
                                                                                        fetchedTransaction?.category = category
                                                                                        fetchedTransaction?.place = place
                                                                                        fetchedTransaction?.date = date
                                                                                        fetchedTransaction?.type = type
                                                                                        fetchedTransaction?.desc = desc
                                                                                        CoreDataService.instance.update(complition: { (success) in
                                                                                            if index == transactions.count - 1 {
                                                                                                complition(result)
                                                                                            }
                                                                                        })
                                                                                    }
                                                                                })
                                                                            }
                                                                        })
                                                                    } else {
                                                                        if index == transactions.count - 1 {
                                                                            complition(result)
                                                                        }
                                                                    }
                                                                })
                                                           
                                                        } else {
                                                                CoreDataService.instance.fetchTransaction(ById: id, withSEId: seid, account: account!, complition: { (fetchedTransaction) in
                                                                    if fetchedTransaction == nil {
                                                                        CoreDataService.instance.saveTransaction(amount: amount, desc: desc, type: type, date: date, place: place, account: account!, category: category!, transfer: nil, se_id: seid, id: id, complition: { (savedTransaction) in
                                                                                if tags.count == 0 {
                                                                                    if index == transactions.count - 1 {
                                                                                        complition(result)
                                                                                    }
                                                                                } else {
                                                                                    for tag in tags {
                                                                                        CoreDataService.instance.saveTag(name: tag, transaction: savedTransaction)
                                                                                    }
                                                                                    if index == transactions.count - 1 {
                                                                                        complition(result)
                                                                                    }
                                                                                }
                                                                        })
                                                                    } else {
                                                                        self.saveTags(transaction: fetchedTransaction!, tags: tags, complition: { (success) in
                                                                            if fetchedTransaction!.amount != amount || fetchedTransaction!.category != category || fetchedTransaction!.place != place || fetchedTransaction!.date != date || fetchedTransaction!.type != type || fetchedTransaction!.desc != desc {
                                                                                fetchedTransaction?.amount = amount
                                                                                fetchedTransaction?.category = category
                                                                                fetchedTransaction?.place = place
                                                                                fetchedTransaction?.date = date
                                                                                fetchedTransaction?.type = type
                                                                                fetchedTransaction?.desc = desc
                                                                                CoreDataService.instance.update(complition: { (success) in
                                                                                    if index == transactions.count - 1 {
                                                                                    complition(result)
                                                                                    }
                                                                                })
                                                                            }
                                                                        })
                                                                    }
                                                                })
                                                           
                                                        }
                                                    }
                                                })
                                            }
                                        })
                                        break
                                    }
                                }
                            }
                        } else {
                            CoreDataService.instance.fetchAccount(ByObjectID: accountID, userID: userID, complition: { (account) in
                                if account == nil {
                                    complition(false)
                                    return
                                } else {
                                    CoreDataService.instance.fetchCategory(ByObjectID: categoryID, userID: userID, complition: { (category) in
                                        if category == nil {
                                            complition(false)
                                            return
                                        } else {
                                            if let transfer = transaction["transfer"]?.string {
                                                CoreDataService.instance.fetchTransaction(ById: transfer, withSEId: seid, account: account!, complition: { (transferTransaction) in
                                                    if transferTransaction != nil {
                                                        CoreDataService.instance.fetchTransaction(ById: id, withSEId: seid, account: account!, complition: { (fetchedTransaction) in
                                                            if fetchedTransaction == nil {
                                                                CoreDataService.instance.saveTransaction(amount: amount, desc: desc, type: type, date: date, place: nil, account: account!, category: category!, transfer: fetchedTransaction, se_id: seid, id: id, complition: { (savedTransaction) in
                                                                    if tags.count == 0 {
                                                                        if index == transactions.count - 1 {
                                                                            complition(result)
                                                                        }
                                                                    } else {
                                                                        for tag in tags {
                                                                            CoreDataService.instance.saveTag(name: tag, transaction: savedTransaction)
                                                                        }
                                                                        if index == transactions.count - 1 {
                                                                            complition(result)
                                                                        }
                                                                    }
                                                                })
                                                            } else {
                                                                self.saveTags(transaction: fetchedTransaction!, tags: tags, complition: { (success) in
                                                                    if fetchedTransaction!.amount != amount || fetchedTransaction!.category != category || fetchedTransaction!.place != nil || fetchedTransaction!.date != date || fetchedTransaction!.type != type || fetchedTransaction!.desc != desc {
                                                                        fetchedTransaction?.amount = amount
                                                                        fetchedTransaction?.category = category
                                                                        fetchedTransaction?.place = nil
                                                                        fetchedTransaction?.date = date
                                                                        fetchedTransaction?.type = type
                                                                        fetchedTransaction?.desc = desc
                                                                        CoreDataService.instance.update(complition: { (success) in
                                                                            if index == transactions.count - 1 {
                                                                                complition(result)
                                                                            }
                                                                        })
                                                                    }
                                                                })
                                                            }
                                                        })
                                                    } else {
                                                        if index == transactions.count - 1 {
                                                            complition(result)
                                                        }
                                                    }
                                                })
                                                
                                            } else {
                                                    CoreDataService.instance.fetchTransaction(ById: id, withSEId: seid, account: account!, complition: { (fetchedTransaction) in
                                                        if fetchedTransaction == nil {
                                                            CoreDataService.instance.saveTransaction(amount: amount, desc: desc, type: type, date: date, place: nil, account: account!, category: category!, transfer: nil, se_id: seid, id: id, complition: { (savedTransaction) in
                                                                if tags.count == 0 {
                                                                    if index == transactions.count - 1 {
                                                                        complition(result)
                                                                    }
                                                                } else {
                                                                    for tag in tags {
                                                                        CoreDataService.instance.saveTag(name: tag, transaction: savedTransaction)
                                                                    }
                                                                    if index == transactions.count - 1 {
                                                                        complition(result)
                                                                    }
                                                                }
                                                            })
                                                        } else {
                                                            self.saveTags(transaction: fetchedTransaction!, tags: tags, complition: { (success) in
                                                                if fetchedTransaction!.amount != amount || fetchedTransaction!.category != category || fetchedTransaction!.place != nil || fetchedTransaction!.date != date || fetchedTransaction!.type != type || fetchedTransaction!.desc != desc {
                                                                    fetchedTransaction?.amount = amount
                                                                    fetchedTransaction?.category = category
                                                                    fetchedTransaction?.place = nil
                                                                    fetchedTransaction?.date = date
                                                                    fetchedTransaction?.type = type
                                                                    fetchedTransaction?.desc = desc
                                                                    CoreDataService.instance.update(complition: { (success) in
                                                                        if index == transactions.count - 1 {
                                                                            complition(result)
                                                                        }
                                                                    })
                                                                }
                                                            })
                                                        }
                                                    })
                                            }
                                        }
                                    })
                                }
                            })
                        }
                    } else {
                        result = false
                        if index == transactions.count - 1 {
                            complition(result)
                        }
                    }
                } else {
                    result = false
                    if index == transactions.count - 1 {
                        complition(result)
                    }
                }
            }
        }
    }
    
    func savePlaces(places: [JSON], complition: @escaping (Bool)->()){
        if places.count == 0 {
            complition(true)
        } else {
            var result = true
            for (index, item) in places.enumerated() {
                if let place = item.dictionary {
                    if let id = place["fsid"]?.string, let address = place["address"]?.string, let name = place["name"]?.string, let latitude = place["latitude"]?.string, let longitude = place["longitude"]?.string {
                        CoreDataService.instance.fetchPlaceById(id: id) { (fetchedPlaces) in
                            if fetchedPlaces.count == 0 {
                                CoreDataService.instance.savePlace(id: id, name: name, address: address, latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0, complition: { (success) in
                                    if !success {
                                        result = false
                                    }
                                    if index == places.count - 1 {
                                        complition(result)
                                    }
                                })
                            } else {
                                for (fetchedIndex, fetchedItem) in fetchedPlaces.enumerated() {
                                    if fetchedItem.name != name || fetchedItem.address != address {
                                        fetchedItem.name = name
                                        fetchedItem.address = address
                                        CoreDataService.instance.update(complition: { (success) in
                                            if !success {
                                                result = false
                                            }
                                            if (index == places.count - 1)  && (fetchedIndex == fetchedPlaces.count - 1){
                                                complition(result)
                                            }
                                        })
                                    } else {
                                        if (index == places.count - 1)  && (fetchedIndex == fetchedPlaces.count - 1){
                                            complition(result)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        result = false
                        if index == places.count - 1 {
                            complition(result)
                        }
                    }
                } else {
                    result = false
                    if index == places.count - 1 {
                        complition(result)
                    }
                }
            }
        }
    }
    
    func saveSECustomers(seCustomers: [JSON], user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
            complition(false)
            return
        }
        if seCustomers.count == 0 {
            complition(true)
        } else {
            var result = true
            for (index, item) in seCustomers.enumerated() {
                if let seCustomer = item.dictionary {
                    if let id = seCustomer["seid"]?.string {
                        CoreDataService.instance.fetchSECustomer(ByID: id, userID: userID) { (seCustomer) in
                            if seCustomer == nil {
                                CoreDataService.instance.saveSECustomer(id: id, user: user, complition: { (savedSECustomer) in
                                    if savedSECustomer == nil {
                                        result = false
                                    }
                                    if index == seCustomers.count - 1 {
                                        complition(result)
                                    }
                                })
                            } else {
                                if index == seCustomers.count - 1 {
                                    complition(result)
                                }
                            }
                        }
                    } else {
                        result = false
                        if index == seCustomers.count - 1 {
                            complition(result)
                        }
                    }
                } else {
                    result = false
                    if index == seCustomers.count - 1 {
                        complition(result)
                    }
                }
            }
        }
    }
    
    func saveSEProviders(seProviders: [JSON], user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
            complition(false)
            return
        }
        if seProviders.count == 0 {
            complition(true)
        } else {
            var result = true
            for (index, item) in seProviders.enumerated() {
                if let seProvider = item.dictionary {
                    if let id = seProvider["seid"]?.string, let name = seProvider["name"]?.string, let secret = seProvider["secret"]?.string, let seCustomerID = seProvider["seCustomer"]?.string {
                        CoreDataService.instance.fetchSEProvider(ById: id, customerID: seCustomerID) { (fetchedSEProviders) in
                            if fetchedSEProviders.count == 0 {
                                CoreDataService.instance.fetchSECustomer(ByID: seCustomerID, userID: userID, complition: { (seCustomer) in
                                    if seCustomer == nil {
                                        result = false
                                        if index == seProviders.count - 1 {
                                            complition(result)
                                        }
                                    } else {
                                        CoreDataService.instance.saveSEProvider(name: name, id: id, secret: secret, customer: seCustomer!, complition: { (savedSEProvider) in
                                            if savedSEProvider == nil {
                                                result = false
                                            }
                                            if index == seProviders.count - 1 {
                                                complition(result)
                                            }
                                        })
                                    }
                                })
                            } else {
                                for (fetchedIndex, fetchedSEProvider) in fetchedSEProviders.enumerated() {
                                    if fetchedSEProvider.secret != secret {
                                        fetchedSEProvider.secret = secret
                                        CoreDataService.instance.update(complition: { (success) in
                                            if !success {
                                                result = false
                                            }
                                            if (index == seProviders.count - 1) && (fetchedIndex == fetchedSEProviders.count - 1){
                                                complition(result)
                                            }
                                        })
                                    } else {
                                        if (index == seProviders.count - 1) && (fetchedIndex == fetchedSEProviders.count - 1){
                                            complition(result)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        result = false
                        if index == seProviders.count - 1 {
                            complition(result)
                        }
                    }
                } else {
                    result = false
                    if index == seProviders.count - 1 {
                        complition(result)
                    }
                }
            }
        }
    }
    
    func saveAccounts(accounts: [JSON], user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
            complition(false)
            return
        }
        if accounts.count == 0 {
            complition(true)
        } else {
            var result = true
            for (index, item) in accounts.enumerated() {
                if let account = item.dictionary {
                    if let id = account["mobAppId"]?.string, let name = account["name"]?.string, let systemName = account["systemName"]?.string, let currency = account["currency"]?.string, let type = account["type"]?.string, let external = account["external"]?.bool {
                        let seId = account["seid"]?.string ?? ""
                        let seProvider = account["seProvider"]?.string ?? ""
                        CoreDataService.instance.fetchAccount(ByID: id, withSEID: seId, seProviderID: seProvider, userID: userID) { (account) in
                            if let account = account {
                                if account.name != name || account.currency != currency || account.external != external || account.type != type{
                                    account.name = name
                                    account.currency = currency
                                    account.external = external
                                    account.type = type
                                    CoreDataService.instance.update(complition: { (success) in
                                        if !success { result = false}
                                        if index == accounts.count - 1 {
                                            complition(result)
                                        }
                                    })
                                } else {
                                    if index == accounts.count - 1 {
                                        complition(result)
                                    }
                                }
                            } else {
                                if seProvider.isEmpty {
                                    CoreDataService.instance.saveAccount(name: name, systemName: systemName, type: type, currency: currency, external: external, user: user, id: id, complition: { (success) in
                                        if success {
                                            if !external {
                                                AccountHelper.instance.currentAccount = id
                                            }
                                        }else{
                                            result = false
                                        }
                                        if index == accounts.count - 1 {
                                            complition(result)
                                        }
                                    })
                                } else {
                                    guard let customerId = user.se_customer?.id else {
                                        result = false
                                        if index == accounts.count - 1 {
                                            complition(result)
                                        }
                                        return
                                    }
                                    CoreDataService.instance.fetchSEProvider(ById: seProvider, customerID: customerId, complition: { (seProviders) in
                                        for seProviderItem in seProviders {
                                            CoreDataService.instance.saveSEAccount(name: name, systemName: systemName, type: type, currency: currency, external: external, seID: seId, seProvider: seProviderItem, user: user, id: id, complition: { (account) in
                                                if account == nil {
                                                    result = false
                                                }
                                                if index == accounts.count - 1 {
                                                    complition(result)
                                                }
                                            })
                                            break
                                        }
                                    })
                                }
                            }
                        }
                    } else {
                        result = false
                        if index == accounts.count - 1 {
                            complition(result)
                        }
                    }
                } else {
                    result = false
                    if index == accounts.count - 1 {
                        complition(result)
                    }
                }
            }
        }
    }
    
    func saveCategories(categories: [JSON], user: User, complition: @escaping (Bool)->()){
        guard let userID = user.id else {
            complition(false)
            return
        }
        if categories.count == 0 {
            complition(true)
        } else {
            var sortedCategories = [CategoryWrapper]()
            for item in categories{
                if let category = item.dictionary {
                    if let id = category["mobAppId"]?.string, let name = category["name"]?.string, let systemName = category["systemName"]?.string, let color = category["color"]?.string {
                        let parent = category["parent"]?.string ?? ""
                        sortedCategories.append(CategoryWrapper(name: name, systemName: systemName, color: color, id: id, parent: parent))
                    }
                }
            }
            if sortedCategories.count == 0 {
                complition(false)
            }
            sortedCategories.sort { (arg0, arg1) -> Bool in
                return arg0.parent.isEmpty
            }
            var result = true;
            for (index, item) in sortedCategories.enumerated() {
                CoreDataService.instance.fetchCategory(ByObjectID: item.id, userID: userID) { (fetchedCategory) in
                        if fetchedCategory != nil {
                            if fetchedCategory?.name != item.name || fetchedCategory?.color != item.color || fetchedCategory?.parent?.id != (item.parent.isEmpty ? nil : item.parent) {
                                    if fetchedCategory?.parent?.id != (item.parent.isEmpty ? nil : item.parent) {
                                        CoreDataService.instance.fetchCategory(ByObjectID: item.parent, userID: userID, complition: { (fetchedParentCategory) in
                                            if fetchedParentCategory != nil {
                                                fetchedCategory?.parent = fetchedParentCategory
                                                fetchedCategory?.name = item.name
                                                fetchedCategory?.color = item.color
                                                CoreDataService.instance.update(complition: { (success) in
                                                    if !success { result = false }
                                                    if index == sortedCategories.count - 1 {
                                                        complition(result)
                                                    }
                                                })
                                            } else {
                                                if index == sortedCategories.count - 1 {
                                                    complition(result)
                                                }
                                            }
                                            
                                        })
                                    } else {
                                        fetchedCategory?.name = item.name
                                        fetchedCategory?.color = item.color
                                        CoreDataService.instance.update(complition: { (success) in
                                            if !success { result = false }
                                            if index == sortedCategories.count - 1 {
                                                complition(result)
                                            }
                                        })
                                    }
                            } else {
                                if index == sortedCategories.count - 1 {
                                    complition(result)
                                }
                            }
                        } else {
                            if item.parent.isEmpty {
                                CoreDataService.instance.saveCategory(name: item.name, color: EncodeDecodeService.instance.returnUIColor(components: item.color), parent: nil, systemName: item.systemName, user: user, id: item.id, complition: { (category) in
                                    if category == nil { result = false }
                                    if index == sortedCategories.count - 1 {
                                        complition(result)
                                    }
                                })
                            } else {
                                CoreDataService.instance.fetchCategory(ByObjectID: item.parent, userID: userID, complition: { (parentCategory) in
                                    if parentCategory != nil {
                                        CoreDataService.instance.saveCategory(name: item.name, color: EncodeDecodeService.instance.returnUIColor(components: item.color), parent: parentCategory, systemName: item.systemName, user: user, id: item.id, complition: { (category) in
                                            if category == nil { result = false }
                                            if index == sortedCategories.count - 1 {
                                                complition(result)
                                            }
                                        })
                                    } else {
                                        if index == sortedCategories.count - 1 {
                                            complition(result)
                                        }
                                    }
                                })
                            }
                        }
                }
            }
        }
    }
}
