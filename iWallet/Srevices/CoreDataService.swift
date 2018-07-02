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
    func saveCategory(name: String, color: UIColor?, parent: Category?, systemName: String = "", user: User, id: String? = nil, lastUpdate: Date? = nil, complition: (Category?) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let category = Category(context: managedContext)
        category.name = name
        category.systemName = systemName
        category.color = EncodeDecodeService.instance.fromUIColorToStr(color: color)
        category.parent = parent
        category.user = user
        category.id = id ?? category.objectID.uriRepresentation().absoluteString
        if let lastUpdate = lastUpdate {
            category.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(category)
        } catch {
            debugPrint("Could not save category: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func fetchCategoryParents(userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "parent == nil AND user.id == %@", userID)
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
    
    func fetchCategoryChildrenByParent(_ parent: Category, userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "parent == %@ AND user.id == %@", parent, userID)
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
    
    func fetchLastCategories(ByDate date: Date, userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "lastUpdate >= %@ AND user.id == %@", date as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category \(error.localizedDescription)")
        }
    }
    
    func fetchCategory(ByName name: String, system: Bool = false, userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: system ? "systemName == %@ AND user.id == %@" : "name == %@ AND user.id == %@", name, userID)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category by name \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchCategory(ByName name: String, WithParent parent: String, userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "name == %@ AND parent.name == %@ AND user.id == %@", name, userID)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category by name \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchCategoryParent(ByName name: String, system: Bool = false, userID: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: system ? "systemName == %@ AND parent == nil AND user.id == %@" : "name == %@ AND parent == nil AND user.id == %@", name, userID)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category by name \(name) \(error.localizedDescription)")
        }
    }
    
    
    func fetchCategory(ByObjectID id: String, userID: String, complition: (_ complete: Category?)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@ AND user.id == %@", id, userID)
        fetchRequest.predicate = predicate
        do{
            let categories = try managedContext.fetch(fetchRequest) as! [Category]
            if categories.count > 0 {
                for item in categories {
                    complition(item)
                    break
                }
            } else {
                complition(nil)
            }
        } catch {
            debugPrint("Could not fetch categories\(error.localizedDescription)")
        }
    }
    
    func fetchAllCategories(complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch categories \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesTurnover(WithStartDate startDate: Date, AndEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["category.name", "category.id", "category.color", "category.parent.name", "account.currency"]
        fetchRequest.propertiesToFetch = ["category.name", "category.id", "category.color", "category.parent.name",  "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.external == %@ AND date >= %@ AND date <= %@ AND account.user.id == %@", NSNumber(value: false),startDate.startOfDay() as CVarArg, endDate.endOfDay() as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesIncome(WithStartDate startDate: Date, AndEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["category.name", "category.id", "category.color", "category.parent.name", "account.currency"]
        fetchRequest.propertiesToFetch = ["category.name", "category.id", "category.color", "category.parent.name",  "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND date >= %@ AND date <= %@ AND account.user.id == %@", NSNumber(value: false), TransactionType.income.rawValue, startDate.startOfDay() as CVarArg, endDate.endOfDay() as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesCosts(WithStartDate startDate: Date, AndEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["category.name", "category.id", "category.color", "category.parent.name", "account.currency"]
        fetchRequest.propertiesToFetch = ["category.name", "category.id", "category.color", "category.parent.name",  "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND date >= %@ AND date <= %@ AND account.user.id == %@", NSNumber(value: false), TransactionType.costs.rawValue, startDate.startOfDay() as CVarArg, endDate.endOfDay() as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesIncome(ByAccount account: String, WithDate date: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["category.name", "category.parent.name", "category.color"]
        fetchRequest.propertiesToFetch = ["category.name", "category.parent.name", "category.color", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.id == %@ AND type == %@ AND date >= %@ AND date <= %@ AND category.user.id == %@", account, TransactionType.income.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchCategoriesCosts(ByAccount account: String, WithDate date: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["category.name", "category.parent.name", "category.color"]
        fetchRequest.propertiesToFetch = ["category.name", "category.parent.name", "category.color", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account.id == %@ AND type == %@ AND date >= %@ AND date <= %@ AND category.user.id == %@", account, TransactionType.costs.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    // Account
    
    func fetchAccounts(bySEProviderID seProviderID: String, userID: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "disabled == false AND se_provider.id == %@ AND user.id == %@", seProviderID, userID)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch accounts \(error.localizedDescription)")
        }
    }
    
    func fetchAccounts(withoutExternal: Bool = true, userID : String, complition: (_ complete: [Account])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = withoutExternal ? NSPredicate(format: "external == %@ AND disabled == %@ AND user.id == %@", NSNumber(value: false), NSNumber(value: false), userID) : NSPredicate(format: "disabled == %@ AND user.id == %@", NSNumber(value: false), userID)
            fetchRequest.predicate = predicate
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            complition(accounts)
        } catch {
            debugPrint("Could not fetch accounts\(error.localizedDescription)")
        }
    }
    
    func fetchAccount(bySystemName name: String, userID : String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "disabled == false AND systemName == %@ AND user.id == %@", name, userID)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by description \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchAccount(byName name: String, userID: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "disabled == false AND name == %@ AND user.id == %@", name, userID)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by description \(name) \(error.localizedDescription)")
        }
    }
    
    func fetchLastAccounts(ByDate date: Date, userID: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "lastUpdate >= %@ AND user.id == %@", date as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account \(error.localizedDescription)")
        }
    }
    // With disabled
    func fetchAccount(bySE_ID id: String, seProviderID: String, userID: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "se_id == %@ AND se_provider.id == %@ AND user.id == %@", id, seProviderID, userID)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by seID \(id) \(error.localizedDescription)")
        }
    }
    // With disabled
    func fetchAccount(ByID id: String, withSEID seid: String, userID: String, complition: (_ complete: Account?)-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate =  seid.isEmpty ? NSPredicate(format: "id == %@ AND user.id == %@", id, userID) : NSPredicate(format: "(id == %@ OR se_id == %@) AND user.id == %@", id, seid, userID)
        fetchRequest.predicate = predicate
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            if accounts.count == 0 {
                complition(nil)
            }
            else {
                for item in accounts {
                    complition(item)
                    break
                }
            }
        } catch {
            debugPrint("Could not fetch account by seID \(seid) \(error.localizedDescription)")
        }
    }
    
    func fetchAccounts(ByObjectIDs ids: [String], userID: String, complition: (_ complete: [Account])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "ANY id IN %@ AND user.id == %@", ids, userID)
        fetchRequest.predicate = predicate
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            complition(accounts)
        } catch {
            debugPrint("Could not fetch account\(error.localizedDescription)")
        }
    }
    
    func fetchAccount(ByObjectID id: String, userID: String, complition: (_ complete: Account?)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "id == %@ AND user.id == %@", id, userID)
        fetchRequest.predicate = predicate
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            if accounts.count == 0 {
                complition(nil)
            }
            else {
                for item in accounts {
                    complition(item)
                    break
                }
            }
        } catch {
            debugPrint("Could not fetch account\(error.localizedDescription)")
        }
    }
    
    
    func saveAccount(name: String, systemName: String, type: String, currency: String, external: Bool = false, user: User, id: String? = nil, lastUpdate: Date? = nil, complition: (Account?) ->()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let account = Account(context: managedContext)
        account.name = name
        account.type = type
        account.currency = currency
        account.external = external
        account.systemName = systemName
        account.user = user
        account.id = id ?? account.objectID.uriRepresentation().absoluteString
        if let lastUpdate = lastUpdate {
            account.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(account)
        } catch {
            debugPrint("Could not save account: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func saveSEAccount(name: String, systemName: String, type: String, currency: String, external: Bool = false, seID: String, seProvider: SEProvider, user: User, id: String? = nil, lastUpdate: Date? = nil, complition: (Account?) ->()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let account = Account(context: managedContext)
        account.name = name
        account.type = type
        account.currency = currency
        account.external = external
        account.systemName = systemName
        account.se_id = seID
        account.se_provider = seProvider
        account.user = user
        account.id = id ?? account.objectID.uriRepresentation().absoluteString
        if let lastUpdate = lastUpdate {
            account.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(account)
        } catch {
            debugPrint("Could not save account: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func remove(object: NSManagedObject, complition: (Bool)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(object)
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
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
    
//    func fetchPlace(ByName name: String,complition: @escaping ([Place])->()){
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
//        let predicate = NSPredicate(format: "name contains[c] %@", name)
//        fetchRequest.predicate = predicate
//        do{
//            let place = try managedContext.fetch(fetchRequest) as! [Place]
//            complition(place)
//        } catch {
//            debugPrint("Could not fetch places\(error.localizedDescription)")
//        }
//    }
    
    func fetchPopularTagsName(ByStr str: String, complition: ([String])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        
        let keypathExp = NSExpression(forKeyPath: "transaction")
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        
        let countDesc = NSExpressionDescription()
        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType
        
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["name"]
        fetchRequest.propertiesToFetch = ["name", countDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "name contains[c] %@ AND transaction.disabled == false", str)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 6
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                var sortedResult = resultArray
                var tagArray = [String]()
                sortedResult.sort { (arg0, arg1) -> Bool in
                    var sum0 = 0
                    var sum1 = 0
                    if let value = arg0["count"] as? Int {
                        sum0 += value
                    }
                    if let value = arg1["count"] as? Int {
                        sum1 += value
                    }
                    return sum0 > sum1
                }
                for item in sortedResult{
                   if let value = item["name"] as? String {
                            tagArray.append(value)
                    }
                }
                complition(tagArray)
            }
        } catch {
            debugPrint("Could not fetch tags \(error.localizedDescription)")
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
    
    //Description
    
    func fetchTransactionsDescriptions(ByStr str: String, complition: ([String])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let sortDescriptor = [NSSortDescriptor(key: "desc", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = ["desc"]
        fetchRequest.propertiesToGroupBy = ["desc"]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.external == %@ AND desc contains[c] %@", NSNumber(value: false), str)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 6
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                var descArray = [String]()
                for item in resultArray{
                    if let value = item["desc"] as? String {
                        descArray.append(value)
                    }
                }
                complition(descArray )
            }
        } catch {
            debugPrint("Could not fetch descriptions \(error.localizedDescription)")
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
    
    func saveTransaction(amount: Double,desc: String?,type: String, date: Date, place: Place?, account: Account, category: Category,transfer: Transaction?, se_id: String = "", id: String? = nil, lastUpdate: Date? = nil, disabled: Bool = false, complition: (Transaction?) ->()){
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
        transaction.se_id = se_id
        transaction.id = id ?? transaction.objectID.uriRepresentation().absoluteString
        transaction.disabled = disabled
        if let lastUpdate = lastUpdate {
            transaction.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(transaction)
        } catch {
            complition(nil)
            debugPrint("Could not save transaction: \(error.localizedDescription)")
        }
    }
    func fetchTransaction(id: String, account: Account, complition: (Transaction?)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account == %@ AND id == %@", account, id)
        fetchRequest.predicate = predicate
        do{
            let transactions = try managedContext.fetch(fetchRequest) as! [Transaction]
            if transactions.count == 0 {
                complition(nil)
            } else {
                for transaction in transactions {
                   complition(transaction)
                    break
                }
            }
        } catch {
            debugPrint("Could not fetch transaction for account \(account.name) \(error.localizedDescription)")
        }
    }
    // With disabled
    func fetchTransaction(ById id: String, withSEId seid: String, account: Account, complition: (Transaction?)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = seid.isEmpty ? NSPredicate(format: "account == %@ AND id == %@", account, id) : NSPredicate(format: "account == %@ AND (id == %@ OR se_id == %@)", account, id, seid)
        fetchRequest.predicate = predicate
        do{
            let transactions = try managedContext.fetch(fetchRequest) as! [Transaction]
            if transactions.count == 0 {
                complition(nil)
            } else {
                for transaction in transactions {
                    complition(transaction)
                    break
                }
            }
        } catch {
            debugPrint("Could not fetch transaction for account \(account.name) \(error.localizedDescription)")
        }
    }
    
    func fetchTransaction(ById id: String, userID: String, complition: (Transaction?)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account.user.id == %@ AND id == %@", userID, id)
        fetchRequest.predicate = predicate
        do{
            let transactions = try managedContext.fetch(fetchRequest) as! [Transaction]
            if transactions.count == 0 {
                complition(nil)
            } else {
                for transaction in transactions {
                    complition(transaction)
                    break
                }
            }
        } catch {
            debugPrint("Could not fetch transaction\(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(ByAccount account: Account, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account == %@ AND disabled == false", account)
        fetchRequest.predicate = predicate
        do{
            let transaction = try managedContext.fetch(fetchRequest) as! [Transaction]
            complition(transaction)
        } catch {
            debugPrint("Could not fetch transactions for account \(account.name) \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(account: Account, date: Date, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account == %@ AND date >= %@ AND date <= %@", account, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
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
    
    func fetchLastTransactions(ByDate date: Date, userID: String, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "account.user.id == %@ AND lastUpdate >= %@", userID, date as CVarArg)
        fetchRequest.predicate = predicate
        do{
            let transaction = try managedContext.fetch(fetchRequest) as! [Transaction]
            complition(transaction)
        } catch {
            debugPrint("Could not fetch transactions \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(account: Account, se_id: String, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account == %@ AND se_id == %@", account, se_id)
        fetchRequest.predicate = predicate
        do{
            let transaction = try managedContext.fetch(fetchRequest) as! [Transaction]
            complition(transaction)
        } catch {
            debugPrint("Could not fetch transactions for account \(account.name) \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(ByDescription description: String, userID: String, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let predicate = NSPredicate(format: "disabled == false AND account.external == %@ AND account.user.id == %@ AND desc == %@", NSNumber(value: false), userID, description)
        let sortDescriptor = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            let transaction = try managedContext.fetch(fetchRequest) as! [Transaction]
            complition(transaction)
        } catch {
            debugPrint("Could not fetch transactions by description \(description) \(error.localizedDescription)")
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
    
    func fetchAccountsTurnoverGroupedByDate(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["date","account.name",  "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["date","account.name",  "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.disabled == false AND account.external == %@ AND account.user.id == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        let sortDescriptor = [NSSortDescriptor(key: "account.name", ascending: true), NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchAccountsIncomeGroupedByDate(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["date","account.name",  "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["date","account.name",  "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.disabled == false AND account.external == %@ AND account.user.id == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, TransactionType.income.rawValue, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        let sortDescriptor = [NSSortDescriptor(key: "account.name", ascending: true), NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchAccountsCostsGroupedByDate(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["date","account.name",  "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["date","account.name",  "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.disabled == false AND account.external == %@ AND account.user.id == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, TransactionType.costs.rawValue, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        let sortDescriptor = [NSSortDescriptor(key: "account.name", ascending: true), NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    
    func fetchAccountsTurnover(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["account.name",  "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["account.name",  "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.disabled == false  AND account.external == %@ AND account.user.id == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchAccountsIncome(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["account.name", "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["account.name", "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.disabled == false AND account.external == %@ AND account.user.id == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, TransactionType.income.rawValue, startDate as CVarArg, endDate as CVarArg)
            fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    
    func fetchTransactions(latitude: Double, longitude: Double, date: Date, userID: String, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let delta = 0.000002
        let predicate = NSPredicate(format: "disabled == false AND date >= %@ AND date <= %@ AND account.external == %@ AND place.latitude >= %f AND place.latitude <= %f AND place.longitude >= %f AND place.longitude <= %f AND account.user.id == %@", date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg, NSNumber(value: false), latitude - delta, latitude + delta, longitude - delta, longitude + delta, userID)
        let sortDescriptor = [NSSortDescriptor(key: "account.name", ascending: true), NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.predicate = predicate
        
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [Transaction] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchTransactions(ByTag tag: String, userID: String, complition: ([Transaction])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let predicate = NSPredicate(format: "transaction.disabled == false AND transaction.account.external == %@ AND name == %@ AND transaction.account.user.id == %@", NSNumber(value: false),tag, userID)
        fetchRequest.propertiesToFetch = ["transaction.id"]
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = predicate
        
        do{
            if let resultArrayID = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                var transactionIDs = [String]()
                for item in resultArrayID {
                    if let transactionID = item["transaction.id"] as? String{
                        transactionIDs.append(transactionID)
                    }
                }
                let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
                let predicate2 = NSPredicate(format: "ANY id IN %@ AND account.user.id == %@ AND disabled == false", transactionIDs, userID)
                let sortDescriptor = [NSSortDescriptor(key: "account.name", ascending: true), NSSortDescriptor(key: "date", ascending: false)]
                fetchRequest2.sortDescriptors = sortDescriptor
                fetchRequest2.predicate = predicate2
                if let resultArray = try managedContext.fetch(fetchRequest2) as? [Transaction] {
                    complition(resultArray)
                }
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    
    func fetchAccountsCosts(WithStartDate startDate: Date, WithEndDate endDate: Date, userID: String, complition: ([NSDictionary])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["account.name",  "account.id", "account.currency"]
        fetchRequest.propertiesToFetch = ["account.name",  "account.id", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.external == %@ AND account.user.id == %@ AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), userID, TransactionType.costs.rawValue, startDate as CVarArg, endDate as CVarArg)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                complition(resultArray)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    
    func evaluateAllIncome(byAccount: Account? = nil, userID: String, complition: (Double)->()){
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
            let predicate = NSPredicate(format: "disabled == false AND account == %@ AND account.external == %@ AND type == %@ AND account.user.id == %@", account, NSNumber(value: false), TransactionType.income.rawValue, userID)
            fetchRequest.predicate = predicate
        } else {
            let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND account.user.id == %@", NSNumber(value: false), TransactionType.income.rawValue, userID)
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
    

    func evaluateAllCosts(byAccount: Account? = nil, userID: String, complition: (Double)->()){
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
                let predicate = NSPredicate(format: "disabled == false AND account == %@ AND account.external == %@ AND type == %@ AND account.user.id == %@", account, NSNumber(value: false), TransactionType.costs.rawValue, userID)
                fetchRequest.predicate = predicate
            } else {
                let predicate = NSPredicate(format: "account.external == %@ AND type == %@ AND account.user.id == %@", NSNumber(value: false), TransactionType.income.rawValue, userID)
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
    
    func fetchLastCurrencyRate(base: String, pair: String, complition: @escaping ([CurrencyRate])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyRate")
        let predicate = NSPredicate(format: "(pair == %@ || pair == %@)", base, pair)
        let sortDescriptor = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        do{
            let currencyRate = try managedContext.fetch(fetchRequest) as! [CurrencyRate]
            complition(currencyRate)
        } catch {
            debugPrint("Could not fetch currency rate by base \(base) and pair \(pair) \(error.localizedDescription)")
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
    
    func fetchPlacesByIds(ids: [String],complition: @escaping ([Place])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let predicate = NSPredicate(format: "ANY id IN %@", ids)
        fetchRequest.predicate = predicate
        do{
            let place = try managedContext.fetch(fetchRequest) as! [Place]
            complition(place)
        } catch {
            debugPrint("Could not fetch places by ids \(error.localizedDescription)")
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
    
    //Places
    
    func fetchPlacesIncome(ByDate date: Date, complition: ([(place: String, amount: Double, latitude: Double, longitude: Double, currency: String)])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["place.name", "place.latitude", "place.longitude", "account.currency"]
        fetchRequest.propertiesToFetch = ["place.name", "place.latitude", "place.longitude", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.external == %@ AND place != nil AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), TransactionType.income.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                var places = [(place: String, amount: Double, latitude: Double, longitude: Double, currency: String)]()
                for resultDict in resultArray {
                    guard let place = resultDict["place.name"] as? String, let amount = resultDict["sum"] as? Double, let currency = resultDict["account.currency"] as? String, let longitude = resultDict["place.longitude"] as? Double, let latitude = resultDict["place.latitude"] as? Double else {continue}
                    places.append((place: place, amount: amount, latitude: latitude, longitude: longitude, currency: currency))
                }
                complition(places)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchPlacesCosts(ByDate date: Date, complition: ([(place: String, amount: Double, latitude: Double, longitude: Double, currency: String)])->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "amount") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["place.name", "place.latitude", "place.longitude", "account.currency"]
        fetchRequest.propertiesToFetch = ["place.name", "place.latitude", "place.longitude", "account.currency", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "disabled == false AND account.external == %@ AND place != nil AND type == %@ AND date >= %@ AND date <= %@", NSNumber(value: false), TransactionType.costs.rawValue, date.startOfMonth() as CVarArg, date.endOfMonth() as CVarArg)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                var places = [(place: String, amount: Double, latitude: Double, longitude: Double, currency: String)]()
                for resultDict in resultArray {
                    guard let place = resultDict["place.name"] as? String, let amount = resultDict["sum"] as? Double, let currency = resultDict["account.currency"] as? String, let longitude = resultDict["place.longitude"] as? Double, let latitude = resultDict["place.latitude"] as? Double else {continue}
                    places.append((place: place, amount: amount, latitude: latitude, longitude: longitude, currency: currency))
                }
                complition(places)
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
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
                debugPrint("Could not update: \(error.localizedDescription)")
                complition(false)
            }
//        }
    }
    
  //User
    
    func saveUser(id: String, name: String, email: String, complition: (_ finished: User?) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let user = User(context: managedContext)
        user.name = name
        user.email = email
        user.id = id
        do{
            try managedContext.save()
            complition(user)
        } catch {
            debugPrint("Could not save user: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func fetchUser(ByEmail email: String,complition: (_ complete: [User])-> () ) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "email == %@", email)
        fetchRequest.predicate = predicate
        do{
            let user = try managedContext.fetch(fetchRequest) as! [User]
            complition(user)
        } catch {
            debugPrint("Could not fetch User \(error.localizedDescription)")
        }
    }
    
    func fetchUser(ByObjectID id: String, complition: (_ complete: User?)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        do{
            let users = try managedContext.fetch(fetchRequest) as! [User]
            if users.count == 0 {
                complition(nil)
            } else {
                for item in users {
                    complition(item)
                }
            }
        } catch {
            debugPrint("Could not fetch User \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    //SaltEdge
    
    func fetchSETransactionMaxID(account: Account, complition: (String?)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        
        let keypathExp = NSExpression(forKeyPath: "se_id") // can be any column
        let expression = NSExpression(forFunction: "max:", arguments: [keypathExp])
        
        let maxDesc = NSExpressionDescription()
        maxDesc.expression = expression
        maxDesc.name = "max"
        maxDesc.expressionResultType = .doubleAttributeType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToFetch = [maxDesc]
        fetchRequest.resultType = .dictionaryResultType
        let predicate = NSPredicate(format: "account == %@", account)
        fetchRequest.predicate = predicate
        do{
            if let resultArray = try managedContext.fetch(fetchRequest) as? [NSDictionary] {
                if resultArray.count > 0 {
                    for item in resultArray {
                        if let max = item["max"] as? Int {
                            complition("\(max)")
                        } else {
                            complition(nil)
                        }
                    }
                } else {
                    complition(nil)
                }
            }
        } catch {
            debugPrint("Could not evaluate income \(error.localizedDescription)")
        }
    }
    
    func fetchSECustomer( complition: (_ complete: [SECustomer])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SECustomer")

        do{
            let seCustomers = try managedContext.fetch(fetchRequest) as! [SECustomer]
            complition(seCustomers)
        } catch {
            debugPrint("Could not fetch SECustomers \(error.localizedDescription)")
        }
    }
    
    func fetchSECustomer(ByID id: String, userID: String, complition: (_ complete: SECustomer?)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SECustomer")
        let predicate = NSPredicate(format: "id == %@ AND user.id == %@", id, userID)
        fetchRequest.predicate = predicate
        do{
            let seCustomers = try managedContext.fetch(fetchRequest) as! [SECustomer]
            if seCustomers.count == 0 {
                complition(nil)
            } else {
                for item in seCustomers {
                    complition(item)
                }
            }
        } catch {
            debugPrint("Could not fetch SECustomers \(error.localizedDescription)")
        }
    }
    
    func fetchLastSECustomer(ByDate date: Date, userID: String, complition: (_ complete: SECustomer?)-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SECustomer")
        let predicate = NSPredicate(format: "lastUpdate >= %@ AND user.id == %@", date as CVarArg, userID)
        fetchRequest.predicate = predicate
        do{
            let seCustomers = try managedContext.fetch(fetchRequest) as! [SECustomer]
            if seCustomers.count == 0 {
                complition(nil)
            } else {
                for item in seCustomers {
                    complition(item)
                }
            }
        } catch {
            debugPrint("Could not fetch SECustomers \(error.localizedDescription)")
        }
    }
    
    
    
    func saveSECustomer(id: String, user: User, lastUpdate: Date? = nil, complition: (_ customer: SECustomer?) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let seCustomer = SECustomer(context: managedContext)
        seCustomer.id = id
        seCustomer.user = user
        if let lastUpdate = lastUpdate {
            seCustomer.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(seCustomer)
        } catch {
            debugPrint("Could not save seCustomer: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func fetchLastSEProviders(ByDate date: Date, userID: String, complition: (_ complete: [SEProvider])-> () ){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SEProvider")
        let predicate = NSPredicate(format: "secustomer.user.id == %@ AND lastUpdate >= %@", userID, date as CVarArg)
        fetchRequest.predicate = predicate
        do{
            let seProviders = try managedContext.fetch(fetchRequest) as! [SEProvider]
            complition(seProviders)
        } catch {
            debugPrint("Could not fetch SEProviders by userID\(userID) \(error.localizedDescription)")
        }
    }
    
    func fetchSEProviders(ByUserID id: String, complition: (_ complete: [SEProvider])-> () ){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SEProvider")
        let predicate = NSPredicate(format: "disabled == false AND secustomer.user.id == %@", id)
        fetchRequest.predicate = predicate
        do{
            let seProviders = try managedContext.fetch(fetchRequest) as! [SEProvider]
            complition(seProviders)
        } catch {
            debugPrint("Could not fetch SEProviders by userID\(id) \(error.localizedDescription)")
        }
    }
    //Only for testing
    func fetchSEProviders(complition: (_ complete: [SEProvider])-> () ){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SEProvider")
        do{
            let seProviders = try managedContext.fetch(fetchRequest) as! [SEProvider]
            complition(seProviders)
        } catch {
            debugPrint("Could not fetch SEProviders \(error.localizedDescription)")
        }
    }
    // With disabled
    func fetchSEProvider(ById id: String, customerID: String, complition: (_ complete: [SEProvider])-> () ) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SEProvider")
        let predicate = NSPredicate(format: "id == %@ AND secustomer.id == %@", id, customerID)
        fetchRequest.predicate = predicate
        do{
            let seProvider = try managedContext.fetch(fetchRequest) as! [SEProvider]
            complition(seProvider)
        } catch {
            debugPrint("Could not fetch SEProvider by id\(id) \(error.localizedDescription)")
        }
    }

    func saveSEProvider(name: String, id: String, secret: String, customer: SECustomer, lastUpdate: Date? = nil, complition: (_ provider: SEProvider?) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let seProvider = SEProvider(context: managedContext)
        seProvider.name = name
        seProvider.id = id
        seProvider.secret = secret
        seProvider.secustomer = customer
        if let lastUpdate = lastUpdate {
            seProvider.lastUpdate = lastUpdate
        }
        do{
            try managedContext.save()
            complition(seProvider)
        } catch {
            debugPrint("Could not save seCustomer: \(error.localizedDescription)")
            complition(nil)
        }
    }
    
    func removeSEProvider(seProvider: SEProvider, complition: (Bool)->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(seProvider)
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
            complition(false)
        }
    }
}
