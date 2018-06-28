//
//  LoginService.swift
//  iWallet
//
//  Created by Sergey Guznin on 6/9/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LoginService {
    static let instance = LoginService()
    func register(name: String, email: String, password: String, complition: @escaping (_ auth: Bool, _ message: String)->()){
        if name.isEmpty {
            return complition(false, "Name must be filled out")
        }
        if email.isEmpty {
            return complition(false, "Email must be filled out")
        }
        if password.isEmpty {
            return complition(false, "Password must be filled out")
        }
        if password.count < 8 {
            return complition(false, "Password have to include 8 or more symbols")
        }
        let parameters = ["name" : name, "email" : email, "password" : password, "currency": Locale.current.currencyCode ?? "USD"]

        Alamofire.request("\(Constants.URL_LOGIN)/api/auth/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.HEADER_REGISTER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                if let auth = json["auth"].bool, let message = json["message"].string{
                    complition(auth, message)
                } else {
                    complition(false, "Internal server error.")
                }
            } else {
                debugPrint(response.result.error as Any)
                complition(false, response.result.error?.localizedDescription ?? "Server error.")
            }
        }
    }
    
    func getLoginToken(email: String, password: String, complition: @escaping (_ auth: Bool, _ message: String, _ token: String)->()){
        if email.isEmpty {
            return complition(false, "Email must be filled out", "")
        }
        if password.isEmpty {
            return complition(false, "Password must be filled out", "")
        }

        let parameters = ["email" : email, "password" : password]
        
        Alamofire.request("\(Constants.URL_LOGIN)/api/auth/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.HEADER_REGISTER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                if let error = json["error"].string {
                    complition(false, error, "")
                } else {
                    if let auth = json["auth"].bool, let token = json["token"].string{
                        complition(auth, auth ? "" : "Internal server error.", token)
                    } else {
                        complition(false, "Internal server error.", "")
                    }
                }
            } else {
                debugPrint(response.result.error as Any)
                complition(false, response.result.error?.localizedDescription ?? "Server error.", "")
            }
        }
    }
    func loginIn(token: String, complition: @escaping (_ auth: Bool, _ message: String, _ id: String, _ name: String, _ email: String)->()){
        if token.isEmpty {
            return complition(false, "Empty token", "", "", "")
        }
        
        var headers = Constants.HEADER_REGISTER
        headers["x-access-token"] = token
        
        Alamofire.request("\(Constants.URL_LOGIN)/api/auth/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                if let id = json["_id"].string, let name = json["name"].string, let email = json["email"].string{
                    complition(true, "", id, name, email)
                } else {
                    complition(false, "Internal server error.", "", "", "")
                }
            } else {
                debugPrint(response.result.error as Any)
                complition(false, response.result.error?.localizedDescription ?? "Server error.", "", "", "")
            }
        }
    }
    
    func resetPassword(email: String, complition: @escaping (_ auth: Bool, _ message: String)->()){
        if email.isEmpty {
            return complition(false, "Email must be filled out")
        }
        
        let parameters = ["email" : email]
        
        Alamofire.request("\(Constants.URL_LOGIN)/api/auth/tryresetpassword", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.HEADER_REGISTER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else {return}
                let json = JSON(data)
                if let auth = json["auth"].bool, let message = json["message"].string{
                    complition(auth, message)
                } else {
                    complition(false, "Internal server error.")
                }
            } else {
                debugPrint(response.result.error as Any)
                complition(false, response.result.error?.localizedDescription ?? "Server error.")
            }
        }
    }
}
