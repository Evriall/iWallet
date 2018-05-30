//
//  LoginHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class LoginHelper {
    static let instance = LoginHelper()
    private let defaults  = UserDefaults.standard
    
    var currentUser: String?{
        get {
                return defaults.string(forKey: Constants.USERID)
            }
        set {
                defaults.set(newValue, forKey: Constants.USERID)
            }
    }

//    var username: String?{
//        get {
//            return defaults.string(forKey: Constants.USERNAME)
//        }
//        set {
//            defaults.set(newValue, forKey: Constants.USERNAME)
//        }
//    }
//
//    var email: String?{
//        get {
//            return defaults.string(forKey: Constants.EMAIL)
//        }
//        set {
//            defaults.set(newValue, forKey: Constants.EMAIL)
//        }
//    }
}
