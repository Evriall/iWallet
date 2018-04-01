//
//  CategoryHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/27/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class CategoryHelper {
    static let instance = CategoryHelper()
    private let defaults  = UserDefaults.standard
    var editableCategories: Bool{
        get {
            return defaults.bool(forKey: Constants.EDITABLE_CATEGORIES)
        }
        set {
            defaults.set(newValue, forKey: Constants.EDITABLE_CATEGORIES)
        }
    }
    var currentCAtegory: String?{
        get {
            return defaults.string(forKey: Constants.CURRENT_CATEGORY)
        }
        set {
            defaults.set(newValue, forKey: Constants.CURRENT_CATEGORY)
        }
    }
    private var categoryChildrenShown = [String: Bool]()
    private let initParentCategories: Array<(String, UIColor, String?)> =
        [(name: "Without category", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), parent: nil),
          (name: "Car", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: nil),
          (name: "Bank", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), parent: nil),
          (name: "Business services", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: nil),
          (name: "Charity", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: nil),
          (name: "State", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: nil),
          (name: "House", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: nil),
          (name: "Pets", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: nil),
          (name: "Eating out of home", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: nil),
          (name: "Health", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: nil),
          (name: "Beauty", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: nil),
          (name: "Mobile communication", color: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), parent: nil),
          (name: "Clothes and footwear", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), parent: nil),
          (name: "Education", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: nil),
          (name: "Other", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: nil),
          (name: "Gifts", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: nil),
          (name: "Food", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: nil),
          (name: "Travels", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: nil),
          (name: "Entertainment", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: nil),
          (name: "Equipment", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: nil),
          (name: "Transport", color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), parent: nil),
          (name: "Transfer", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: nil)
        ]
    private let initChildrenCategories: Array<(String, UIColor, String)> =
        [
         (name: "Autochemistry", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Repair parts", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Accessories", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Washing", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Toll roads", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Parking", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Service", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Insurance", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
         (name: "Fuel", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "Car"),
      
         (name: "Tax", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "State"),
         (name: "Fee", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "State"),
         (name: "Penalty", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "State"),
        
         (name: "Lease", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Household chemicals", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Household services", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Gas", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Rent", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Furniture", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Repairs", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Insurance", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Phone", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         (name: "Electricity", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "House"),
         
         (name: "Accessories & toys", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "Pets"),
         (name: "Veterinary services", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "Pets"),
         (name: "Nutrition", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "Pets"),
         (name: "Medications", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "Pets"),
         
         (name: "Coffe house", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "Eating out of home"),
         (name: "Lunch", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "Eating out of home"),
         (name: "Restaurant", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "Eating out of home"),
         (name: "Fast food", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "Eating out of home"),
         
         (name: "Pharmacy", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "Health"),
         (name: "Inventory", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "Health"),
         (name: "Medical services", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "Health"),
         (name: "Sport", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "Health"),
         (name: "Insurance", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "Health"),
         
         (name: "Сosmetics", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "Beauty"),
         (name: "Beauty salon", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "Beauty"),
         
         (name: "Accessories", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), parent: "Clothes and footwear"),
         (name: "Adult", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), parent: "Clothes and footwear"),
         (name: "Children`s", color: #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), parent: "Clothes and footwear"),
         
         (name: "Books", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "Education"),
         (name: "Services", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "Education"),
         
         (name: "Car rent", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Tickets", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Visas", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Hotel", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Souvenirs", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Insurance", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         (name: "Services", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "Travels"),
         
         (name: "Leisure", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Bar, club", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Games, soft", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Books", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Cinema, theatre", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Museums", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Music, Video", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Press", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         (name: "Hobbies", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "Entertainment"),
         
         (name: "Household appliances", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "Equipment"),
         (name: "Electronics", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "Equipment"),
         
         (name: "Public transport", color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), parent: "Transport"),
         (name: "Taxi", color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), parent: "Transport")
    ]
    // Methods to check and set children category shown
    func check(categoryName: String) -> Bool {
        return categoryChildrenShown[categoryName] ?? false
    }
    
    func set(categoryName: String, isShown: Bool){
        categoryChildrenShown[categoryName] = isShown
    }
    
    func clear(){
        categoryChildrenShown = [:]
    }
    
    // Init Categories by array
    
    func initCategories() {
        for item in initParentCategories {
            CoreDataService.instance.saveCategory(name: item.0, color: item.1, parent: nil, complition: { (success) in
                if !success {
                    print("Can`t create \(item.0) in DB")
                }
            })
        }
        
        for item in initChildrenCategories {
            CoreDataService.instance.fetchCategory(ByName: item.2, complition: { (parent) in
                for  element in parent {
                    CoreDataService.instance.saveCategory(name: item.0, color: item.1, parent: element, complition: { (success) in
                        if !success {
                            print("Can`t create \(item.0) in DB")
                        }
                    })
                }
            })
        }
        
    }
    
}
