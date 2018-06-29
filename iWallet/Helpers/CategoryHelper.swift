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
        [
         (name: "cost_of_goods", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: nil),
         (name: "uncategorized", color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), parent: nil),
         (name: "financials", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: nil),
         (name: "human_resources", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: nil),
         (name: "income", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: nil),
         (name: "insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: nil),
         (name: "office", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: nil),
         (name: "services", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: nil),
         (name: "taxes", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: nil),
         (name: "transport", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: nil),
         (name: "utilities", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: nil),
         (name: "education", color: #colorLiteral(red: 0.2779290954, green: 0.0474625199, blue: 0.7476566407, alpha: 1), parent: nil),
         (name: "entertainment", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: nil),
         (name: "fees_and_charges", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: nil),
         (name: "food_and_dining", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: nil),
         (name: "gifts_and_donations", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: nil),
         (name: "health_and_fitness", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: nil),
         (name: "home", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: nil),
         (name: "kids", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: nil),
         (name: "pets", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: nil),
         (name: "shopping", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: nil),
         (name: "transfer", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: nil),
         (name: "travel", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: nil)
         
    ]
    private let initChildrenCategories: Array<(String, UIColor, String)> =
        [
            (name: "raw_materials", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: "cost_of_goods"),
            (name: "merchandise", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: "cost_of_goods"),
            
            (name: "dividends", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: "financials"),
            (name: "donations", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: "financials"),
            (name: "interest", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: "financials"),
            (name: "fees", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: "financials"),
            (name: "fines", color: #colorLiteral(red: 0.9254902005, green: 0.1473733577, blue: 0, alpha: 1), parent: "financials"),
            
            (name: "wages", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: "human_resources"),
            (name: "bonus", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: "human_resources"),
            (name: "social_security", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: "human_resources"),
            (name: "education_and_trainings", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: "human_resources"),
            (name: "staff_outsourcing", color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), parent: "human_resources"),
            
            (name: "investment", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            (name: "sales", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            (name: "returns", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            (name: "bonus", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            (name: "investment_income", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            (name: "paycheck", color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), parent: "income"),
            
            (name: "business_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "liability_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "health_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "equipment_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "proffessional_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "car_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "health_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "life_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            (name: "property_insurance", color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), parent: "insurance"),
            
            (name: "office_rent", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "office"),
            (name: "equipment", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "office"),
            (name: "software", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "office"),
            (name: "office_supplies", color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1), parent: "office"),

            (name: "contractors", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "accounting", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "legal", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "consultancy", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "storage", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "marketing", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "online_subscriptions", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "advertising", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "office_supplies", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            (name: "shipping", color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), parent: "services"),
            
            (name: "vat", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            (name: "federal_taxes", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            (name: "property_taxes", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            (name: "income_taxes", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            (name: "duty_taxes", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            (name: "tax_return", color: #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1), parent: "taxes"),
            
            (name: "shipping", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "leasing", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "gas_and_fuel", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "taxi", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "car_rental", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "parking", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "public_transportation", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            (name: "service_and_parts", color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), parent: "transport"),
            
            (name: "internet", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            (name: "phone", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            (name: "water", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            (name: "gas", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            (name: "electricity", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            (name: "television", color: #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), parent: "utilities"),
            
            (name: "books_and_supplies", color: #colorLiteral(red: 0.2779290954, green: 0.0474625199, blue: 0.7476566407, alpha: 1), parent: "education"),
            (name: "student_loan", color: #colorLiteral(red: 0.2779290954, green: 0.0474625199, blue: 0.7476566407, alpha: 1), parent: "education"),
            (name: "btuition", color: #colorLiteral(red: 0.2779290954, green: 0.0474625199, blue: 0.7476566407, alpha: 1), parent: "education"),
            
            (name: "amusement", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: "entertainment"),
            (name: "arts", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: "entertainment"),
            (name: "games", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: "entertainment"),
            (name: "movies_and_music", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: "entertainment"),
            (name: "newspapers_and_magazines", color: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), parent: "entertainment"),
            
            (name: "provider_fee", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: "fees_and_charges"),
            (name: "loans", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: "fees_and_charges"),
            (name: "service_fee", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: "fees_and_charges"),
            (name: "taxes", color: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), parent: "fees_and_charges"),
            
            (name: "alcohol_and_bars", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: "food_and_dining"),
            (name: "cafes_and_restaurants", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: "food_and_dining"),
            (name: "groceries", color: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1), parent: "food_and_dining"),
            
            (name: "charity", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "gifts_and_donations"),
            (name: "gifts", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "gifts_and_donations"),

            (name: "doctor", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "health_and_fitness"),
            (name: "personal_care", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "health_and_fitness"),
            (name: "pharmacy", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "health_and_fitness"),
            (name: "sports", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "health_and_fitness"),
            (name: "wellness", color: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1), parent: "health_and_fitness"),
            
            (name: "home_improvement", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "home"),
            (name: "home_services", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "home"),
            (name: "home_supplies", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "home"),
            (name: "mortgage_and_rent", color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), parent: "home"),
            
            (name: "allowance", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            (name: "babysitter_and_daycare", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            (name: "baby_supplies", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            (name: "child_support", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            (name: "kids_activities", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            (name: "toys", color: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), parent: "kids"),
            
            (name: "pet_food_and_supplies", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: "pets"),
            (name: "pet_grooming", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: "pets"),
            (name: "veterinary", color: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1), parent: "pets"),
            
            (name: "clothing", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "shopping"),
            (name: "electronics_and_software", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "shopping"),
            (name: "cporting_goods", color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), parent: "shopping"),
            
            (name: "hotel", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "travel"),
            (name: "transportation", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "travel"),
            (name: "vacation", color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), parent: "travel"),
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
    func textNameCategory(category: Category?) -> String{
        guard let category = category else {
            return ""
        }
        guard let name = category.name else {return ""}
        guard let parentName = category.parent?.name else {return name}
        return "\(parentName)\n\(name)"
    }
    // Init Categories by array
    
//    func initCategories(userID: String, complition: @escaping (Bool)->()) {
//        CoreDataService.instance.fetchUser(ByObjectID: userID) { (user) in
//            guard let user = user else {
//                complition(false)
//                return
//            }
//            for (index, item) in initParentCategories.enumerated() {
//                CoreDataService.instance.saveCategory(name: item.0.replacingOccurrences(of: "_", with: " "), color: item.1, parent: nil, systemName: item.0, user: user, complition: { (parent) in
//                    if parent == nil {
//                        debugPrint("Can`t create \(item.0) in DB")
//                    } else {
//                        for childItem in initChildrenCategories {
//                            if childItem.2 == item.0 {
//                                CoreDataService.instance.saveCategory(name: childItem.0.replacingOccurrences(of: "_", with: " "), color: childItem.1, parent: parent, systemName: childItem.0, user: user, complition: { (category) in
//                                    if category == nil {
//                                        print("Can`t create \(childItem.0) in DB")
//                                    }
//                                    if index == initParentCategories.count - 1 {
//                                        complition(true)
//                                    }
//                                })
//                            } else {
//                                if index == initParentCategories.count - 1 {
//                                    complition(true)
//                                }
//                            }
//                        }
//                    }
//                })
//            }
//        }
//
//    }
    
}
