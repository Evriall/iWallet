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
    func saveCategory(name: String, color: UIColor?, parent: Category?, complition: (_ finished: Bool) ->()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let category = Category(context: managedContext)
        category.name = name
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
    
    func fetchParents(complition: (_ complete: [Category])-> ()) {
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
    
    func fetchChildrenByParent(_ parent: Category, complition: (_ complete: [Category])-> ()) {
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
    
    func fetch(ByName name: String, complition: (_ complete: [Category])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do{
            let category = try managedContext.fetch(fetchRequest) as! [Category]
            complition(category)
        } catch {
            debugPrint("Could not fetch category by name \(name) \(error.localizedDescription)")
        }
    }
    
    // Account
    
    func fetchAccounts(complition: (_ complete: [Account])-> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        do{
            let accounts = try managedContext.fetch(fetchRequest) as! [Account]
            complition(accounts)
        } catch {
            debugPrint("Could not fetch accounts\(error.localizedDescription)")
        }
    }
    
    func fetchAccount(byDescription description: String, complition: (_ complete: [Account])-> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "description == %@", description)
        fetchRequest.predicate = predicate
        do{
            let account = try managedContext.fetch(fetchRequest) as! [Account]
            complition(account)
        } catch {
            debugPrint("Could not fetch account by description \(description) \(error.localizedDescription)")
        }
    }
    
    func saveAccount(name: String, type: String, currency: String, complition: (Bool) ->()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let account = Account(context: managedContext)
        account.name = name
        account.type = type
        account.currency = currency
        do{
            try managedContext.save()
            complition(true)
        } catch {
            debugPrint("Could not save account: \(error.localizedDescription)")
            complition(false)
        }
    }
    
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
