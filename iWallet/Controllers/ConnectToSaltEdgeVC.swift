//
//  ConnectToSaltEdgeVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/25/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import WebKit
import SaltEdge
import PKHUD
import Alamofire

class ConnectToSaltEdgeVC: UIViewController {
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var webView: SEWebView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    private var providers: [(name : String, id: String, countryCode: String)] = []
    private var filteredProviders: [(name : String, id: String, countryCode: String)] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var customer: SECustomer?
    private var user: User?
    
    var delegate: UpdateProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.stateDelegate = self
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchUser(ByObjectID: currentUser) { (user) in
            guard let user = user else {
                continueBtn.isHidden = true
                return
            }
            self.user = user
        }
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        delegate?.update()
        dismissDetail()
    }
    
    func requestToken() {
            HUD.show(.labeledProgress(title: "Requesting Token", subtitle: nil))
            let tokenParams = SECreateTokenParams(fetchScopes: ["accounts", "transactions"], returnTo: "http://httpbin.org", javascriptCallbackType: "iframe")
            // Check if SERequestManager will call handleTokenResponse
            SERequestManager.shared.createToken(params: tokenParams) { [weak self] response in
                self?.handleTokenResponse(response)
            }
    }
    
    private func handleTokenResponse(_ response: SEResult<SEResponse<SETokenResponse>>) {
        switch response {
        case .success(let value):
            HUD.hide(animated: true)
            if let url = URL(string: value.data.connectUrl) {
                let request = URLRequest(url: url)
                webView.load(request)
                webView.isHidden = false
            }
        case .failure(let error):
            HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
        }
    }
   
    @IBAction func continueBtnPressed(_ sender: Any) {
        if !NetworkReachabilityManager()!.isReachable {
            HUD.flash(.labeledError(title: "Error", subtitle: "There are no internet connections"), delay: 3.0)
            return
        }
        infoLbl.isHidden = true
        webView.isHidden = false
        continueBtn.isHidden = true
        
        guard let user = user else {return}
            if let customer = user.se_customer, let secret = user.se_customer?.id {
                self.customer = customer
                SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
                SERequestManager.shared.set(customerSecret: secret)
                requestToken()
            } else {
                if let email = user.email {
                    SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
                    let params = SECustomerParams(identifier: email)
                    SERequestManager.shared.createCustomer(with: params) { response in
                        switch response {
                        case .success(let value):
                            CoreDataService.instance.saveSECustomer(id: value.data.secret, user: user, lastUpdate:  Date(), complition: { (customer) in
                                if let customer = customer {
                                    self.customer = customer
                                    SERequestManager.shared.set(customerSecret: value.data.secret)
                                    self.requestToken()
                                }
                            })
                        case .failure(let error):
                            HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
                        }
                    }
                }
            }
    }
}

extension ConnectToSaltEdgeVC: SEWebViewDelegate {

    func webView(_ webView: SEWebView, didReceiveCallbackWithResponse response: SEConnectResponse) {
        switch response.stage {
        case .success:
            if let secret = response.secret, let id = response.loginId {
                guard let customer = self.customer else {
                    HUD.flash(.labeledError(title: "Can`t fetch data", subtitle: nil), delay: 3.0)
                    return
                }
                if !secret.isEmpty && !id.isEmpty {
                    SaltEdgeHelper.instance.initialFetchData(Provider: id, ProviderSecret: secret, customer: customer) { (success) in
                        if success {
                            HUD.flash(.labeledSuccess(title: "Finished loading data", subtitle: ""))
                        } else {
                            HUD.flash(.labeledError(title: "Data loaded with errors", subtitle: ""))
                        }
                    }
                }
            }
        case .fetching:
            debugPrint("Fetching data")
        case .error:
            HUD.flash(.labeledError(title: "Can`t fetch login", subtitle: nil), delay: 3.0)
        }
    }
    
    func webView(_ webView: SEWebView, didReceiveCallbackWithError error: Error) {
        HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
    }
}

