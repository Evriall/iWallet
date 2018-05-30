//
//  SaltEdgeHelper.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/26/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SECustomerResult {
    case success(String)
    case failure(Error)
}


class SaltEdgeService {
    func createCustomer(name: String, complition: @escaping (_ complete: SECustomerResult)-> ()){
        let params = JSON(["data":["identifier": name]])
//        Alamofire.upload(params, to: Constants.URL_SE_CREATE_CUSTOMER, method: .post, headers: Constants.HEADER_SE).responseJSON { (response) in
//            if response.result.error == nil {
//                                guard let data = response.data else {return}
//                                let json = JSON(data)
//                                if let jsonData = json["data"].dictionary {
//                                    if let id = jsonData["id"]?.string {
//                                    }
//                                }
//                            } else {
//                                debugPrint(response.result.error as Any)
//                                complition(.failure(response.result.error))
//                            }
//        }
//        Alamofire.request("\(Constants.URL_SE_CREATE_CUSTOMER)", method: .get, parameters: params, encoding: JSONEncoding.default, headers: Constants.HEADER_SE).responseJSON { (response) in
//            if response.result.error == nil {
//                guard let data = response.data else {return}
//                let json = JSON(data)
//                if let jsonData = json["data"].dictionary {
//                    if let id = jsonData["id"]?.string {
//                    }
//                }
//            } else {
//                debugPrint(response.result.error as Any)
//                complition(response.result.error)
//            }
//        }
    }
}
