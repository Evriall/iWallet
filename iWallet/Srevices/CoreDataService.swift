//
//  CoreDataService.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService{
    static let instance = CoreDataService()
    
    // Category
    func saveCategory(name: String, color: UIColor?, parent: Category?, system: Bool = false, complition: (_ finished: Bool) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let category = Category(context: managedContext)
        category.name = name
        category.systemName = system ? name : ""
        category.color = EncodeDecodeService.instance.fromUIColorToStr(color: color)
        category.parent = parent
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not save category: \(error.localizedDescription)")
            complition(false)
        }
    }
    
    func fetchCategoryParents(complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "parent == nil")
        let sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch categories\(error.localizedDescription)")
        }
    }
    
    func fetchCategoryChildrenByParent(_ parent: Category, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "parent == %@", parent)
        let sortDescriptor = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch categories by parent \(parent.name) \(error.localizedDescription)")
        }
    }
    
    func fetchCategory(ByName name: String, system: Bool = false, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: system ? "systemName == %@" : "name == %@", name)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category by name \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchCategory(ByObjectID id: String, complition: (_ complete: Category)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        do{
            let categories = try managedContext.fetch(fetchRequest) as! [Category]
            for item in categories {
                if item.objectID.uriRepresentation().absoluteString == id {
                    complition(item)
                }
            }
        } catch {
            debugPrint("Could not fetch categories\(error.localizedDescription)")
        }
    }
    
    // Account
    
    func fetchAccounts(withoutExternal: Bool = true, complition: (_ complete: [Account])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        if withoutExternal {
            let predicate = NSPredicate(format: "external == %@", NSNumber(value: false))
            fetchRequest.predicate = predicate
        }
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            complition(accounts)
        } catch {
            debugPrint("Could not fetch accounts\(error.localizedDescription)")
        }
    }
    
    func fetchAccount(bySystemName name: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "systemName == %@", name)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by description \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchAccount(byName name: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by description \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchAccount(ByObjectID id: String, complition: (_ complete: Account)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            for item in accounts {
                if item.objectID.uriRepresentation().absoluteString == id {
                    complition(item)
                }
            }
        } catch {
            debugPrint("Could not fetch account\(error.localizedDescription)")
        }
    }
    
    
    func saveAccount(name: String, type: String, currency: String, external: Bool = false, complition: (Bool) ->()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let account = Account(context: managedContext)
        account.name = name
        account.type = type
        account.currency = currency
        account.external = external
        account.systemName = external ? name : ""
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not save account: \(error.localizedDescription)")
            complition(false)
        }
    }
    
    //Tag
    func saveTag(name: String, transaction: Transaction) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let tag = Tag(context: managedContext)
        tag.name = name
        tag.transaction = transaction
        do{
            try managedContext.save()
        } catch {
            debugPrint("Could not save tag: \(error.localizedDescription)")
        }
    }
    
    func fetchTag(name: String, transaction: Transaction, complition: (_ complete: [Tag])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let predicate = NSPredicate(format: "name == %@ && transaction == %@", name, transaction)
        fetchRequest.predicate = predicate
        do{
            let tag = try managedContext.fetch(fetchRequest) as! [Tag]
            complition(tag)
        } catch {
            debugPrint("Could not fetch tag \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchTags(transaction: Transaction, complition: (_ complete: [Tag])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let predicate = NSPredicate(format: "transaction == %@", transaction)
        fetchRequest.predicate = predicate
        do{
            let tag = try managedContext.fetch(fetchRequest) as! [Tag]
            complition(tag)
        } catch {
            debugPrint("Could not fetch tags \(error.localizedDescription)")
        }
    }
    
    func removeTag(tag: Tag){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(tag)
        do{
            try managedContext.save()
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
    
    //Photo
    
    func savePhoto(name: String, image: UIImage, transaction: Transaction) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let photo = Photo(context: managedContext)
        photo.name = name
        photo.data = UIImagePNGRepresentation(image)
        photo.transaction = transaction
        do{
            try managedContext.save()
        } catch {
            debugPrint("Could not save photo: \(error.localizedDescription)")
        }
    }
    
    func fetchPhoto(name: String, complition: (_ complete: [Photo])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do{
            let photo = try managedContext.fetch(fetchRequest) as! [Photo]
            complition(photo)
        } catch {
            debugPrint("Could not fetch photos \(error.localizedDescription)")
        }
    }
    
    func fetchPhotos(transaction: Transaction, complition: (_ complete: [Photo])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "transaction == %@", transaction)
        fetchRequest.predicate = predicate
        do{
            let photo = try managedContext.fetch(fetchRequest) as! [Photo]
            complition(photo)
        } catch {
            debugPrint("Could not fetch photos \(error.localizedDescription)")
        }
    }
    
    func removePhoto(_ photo: Photo){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(photo)
        do{
            try managedContext.save()
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
    
    //Transaction
    
    func saveTransaction(amount: Double,desc: String?,type: String, date: Date, place: Place?, account: Account, category: Category,transfer: Transaction?, complition: (Transaction) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let transaction = Transaction(context: managedContext)
        transaction.amount = amount
        transaction.desc = desc
        transaction.type = type
        transaction.date = date
        transaction.place = place
        transaction.account = account
        transaction.category = category
        transaction.transfer = transfer
        do{
            try managedContext.save()
            complition(transaction)
        } catch {
            debugPrint("Could not save transaction: \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(account: Account, date: Date, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "account == %@ AND date >= %@ AND date <= %@", account, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
        let sortDescriptor = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
        do{
            let transaction = try managedContext.fetch(fetchRequest) as! [Transaction]
            complition(transaction)
        } catch {
            debugPrint("Could not fetch transactions for account \(account.name) \(error.localizedDescription)")
        }
    }
    
    func removeTransaction(transaction: Transaction){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(transaction)
        do{
            try managedContext.save()
        } catch {
            debugPrint("Could not remove transaction: \(error.localizedDescription)")
        }
    }
    
    func fetchAccountsIncome(ByDate date: Date, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["account.name"]
        fetchRequest.propertiesToFetch = ["account.name", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), TransactionType.income.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
            fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchAccountsCosts(ByDate date: Date, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["account.name"]
        fetchRequest.propertiesToFetch = ["account.name", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), TransactionType.costs.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    
    func evaluateAllIncome(byAccount: Account? = nil, complition: (Double)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        if let account = byAccount {
            let predicate = NSPredicate(format: "account == %@ AND account.external == %@ AND type == %@", account, NSNumber(value: false), TransactionType.income.rawValue)
            fetchRequest.predicate = predicate
        } else {
            let predicate = NSPredicate(format: "account.external == %@ AND type == %@", NSNumber(value: false), TransactionType.income.rawValue)
            fetchRequest.predicate = predicate
        }
        
        
        do{
            let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary]
            if let result = resultArray {
                for item in result {
                    if let sum = item["sum"] {
                        if let sumDouble = sum as? Double{
                            complition(sumDouble)
                        }
                    }
                }
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    

    func evaluateAllExpanse(byAccount: Account? = nil, complition: (Double)->()){
            guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
            
            let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
            let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
            
            let sumDesc = NSExpressionDescription()
            sumDesc.expression = expression
            sumDesc.name = "sum"
            sumDesc.expressionResultType = .doubleAttributeType
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.propertiesToFetch = [sumDesc]
            fetchRequest.resultType = .dictionaryResultType
            if let account = byAccount {
                let predicate = NSPredicate(format: "account == %@ AND account.external == %@ AND type == %@", account, NSNumber(value: false), TransactionType.costs.rawValue)
                fetchRequest.predicate = predicate
            } else {
                let predicate = NSPredicate(format: "account.external == %@ AND type == %@", NSNumber(value: false), TransactionType.income.rawValue)
                fetchRequest.predicate = predicate
            }
            
            
            do{
                let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary]
                if let result = resultArray {
                    for item in result {
                        if let sum = item["sum"] {
                            if let sumDouble = sum as? Double{
                                complition(sumDouble)
                            }
                        }
                    }
                }
            } catch {
                debugPrint("Could not evaluate income \(error.localizedDescription)")
            }
        }
    
    //Currency
    
    func fetchCurrenciesFromAccount(complition: (_ complete: [String])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        var currencies = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let keypathExp = NSExpression(forKeyPath: "currency") // can be any column
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["currency"]
        fetchRequest.propertiesToFetch = ["currency", countDesc]
        fetchRequest.resultType = .dictionaryResultType
 
        do{
            let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary]
            if let result = resultArray {
                for item in result {
                    if let currency = item["currency"] {
                        if let currencyStr = currency as? String{
                            currencies.append(currencyStr)
                        }
                    }
                }
                complition(currencies)
            }
        } catch {
            debugPrint("Could not fetch currencies \(error.localizedDescription)")
        }
        
    }
    
    
    func fetchCurrenciesFromCurrencyRate(complition: (_ complete: [String])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        var currencies = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["pair"]
        fetchRequest.propertiesToFetch = ["pair"]
        fetchRequest.resultType = .dictionaryResultType
        
        do{
            let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary]
            if let result = resultArray {
                for item in result {
                    if let currency = item["pair"] {
                        if let currencyStr = currency as? String{
                            currencies.append(currencyStr)
                        }
                    }
                }
                complition(currencies)
            }
        } catch {
            debugPrint("Could not fetch currencies \(error.localizedDescription)")
        }
        
    }
    
    //CurrencyRate
    
    func saveCurrencyRate(base: String, pair: String, rate: Double, date: Date, complition: @escaping (Bool)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let currencyRate = CurrencyRate(context: managedContext)
        currencyRate.base = base
        currencyRate.pair = pair
        currencyRate.rate = rate
        currencyRate.date = date.startOfDay()
        do{
            try managedContext.save()
            complition(true)
        } catch {
            complition(false)
            debugPrint("Could not save transaction: \(error.localizedDescription)")
        }
    }
    
    
    func fetchCurrencyRate(base: String, pair: String, date: Date, complition: @escaping ([CurrencyRate])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        let predicate = NSPredicate(format: "(pair == %@ || pair == %@) AND date == %@", base, pair, date.startOfDay() as CVarArg)
        fetchRequest.predicate = predicate
        do{
            let currencyRate = try managedContext.fetch(fetchRequest) as! [CurrencyRate]
            complition(currencyRate)
        } catch {
            debugPrint("Could not fetch currency rate by base \(base) and pair \(pair) and date \(date)\(error.localizedDescription)")
        }
    }
    
    //Places
    func savePlace(id: String, name: String, address: String, latitude: Double, longitude: Double, complition: @escaping (Bool)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let place = Place(context: managedContext)
        place.id = id
        place.name = name
        place.address = address
        place.latitude = latitude
        place.longitude = longitude
        place.date = Date()
        do{
            try managedContext.save()
            complition(true)
        } catch {
            complition(false)
            debugPrint("Could not save transaction: \(error.localizedDescription)")
        }
    }
    
    func fetchPlacesByLocationRegion(startLatitude: Double, endLatitude: Double, startLongitude: Double, endLongitude: Double, complition: @escaping ([Place])->()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", startLatitude, endLatitude, startLongitude, endLongitude)
        fetchRequest.predicate = predicate
        do{
            let place = try managedContext.fetch(fetchRequest) as! [Place]
            complition(place)
        } catch {
            debugPrint("Could not fetch place by region\(error.localizedDescription)")
        }
    }
    
    func fetchPlaceById(id: String,complition: @escaping ([Place])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        do{
            let place = try managedContext.fetch(fetchRequest) as! [Place]
            complition(place)
        } catch {
            debugPrint("Could not fetch place by id \(id)\(error.localizedDescription)")
        }
    }
    
    func fetchPlace(ByName name: String,complition: @escaping ([Place])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let predicate = NSPredicate(format: "name contains[c] %@", name)
        fetchRequest.predicate = predicate
        do{
            let place = try managedContext.fetch(fetchRequest) as! [Place]
            complition(place)
        } catch {
            debugPrint("Could not fetch places\(error.localizedDescription)")
        }
    }
    
    func fetchLastPlaces(limit: Int = 15,complition: @escaping ([Place])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let predicate = NSPredicate(format: "ANY transactions != nil")
        let sortDescriptor = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.fetchLimit = limit
        do{
            let place = try managedContext.fetch(fetchRequest) as! [Place]
            complition(place)
        } catch {
            debugPrint("Could not fetch last places \(error.localizedDescription)")
        }
    }
    
    // General
    func update(complition: (_ complete: Bool)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//        if managedContext.hasChanges {
            do{
                try managedContext.save()
                complition(true)
            } catch {
                debugPrint("Could not save category: \(error.localizedDescription)")
                complition(false)
            }
//        }
    }
    
//    func removeGoal(atIndexPath indexPath: IndexPath){
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//        managedContext.delete(goals[indexPath.row])
//        do{
//            try managedContext.save()
//        } catch {
//            debugPrint("Could not remove: \(error.localizedDescription)")
//        }
//    }
}
