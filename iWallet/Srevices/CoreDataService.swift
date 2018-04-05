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
    
    //Transaction
    
    func saveTransaction(amount: Double,desc: String?,type: String, date: Date, latitude: String?, longitude: String?, place: String?, account: Account, category: Category,transfer: Transaction?, complition: (Transaction) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let transaction = Transaction(context: managedContext)
        transaction.amount = amount
        transaction.desc = desc
        transaction.type = type
        transaction.date = date
        transaction.latitude = latitude
        transaction.longitude = longitude
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
                let predicate = NSPredicate(format: "account == %@ AND account.external == %@ AND type == %@", account, NSNumber(value: false), TransactionType.expance.rawValue)
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
    
//    func evaluateAllIncome(byAccount account: Account, complition: (Double)->()){
//
//    }
    
    // General
    func update(complition: (_ complete: Bool)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not save category: \(error.localizedDescription)")
            complition(false)
        }
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
