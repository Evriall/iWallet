//
//  SettingsVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/27/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import Alamofire
import SaltEdge
import PKHUD

class SettingsVC: UIViewController {

    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var categoryEditableSwitch: UISwitch!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fetchAccountBtn: UIButton!
    @IBOutlet weak var updateAccountBtn: ButtonWithRightImage!
    
    var providers = [SEProvider]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryEditableSwitch.setOn(CategoryHelper.instance.editableCategories, animated: true)
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        tableView.tableFooterView = UIView()
        fetchAccountBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        updateAccountBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchProviders()
    }
    
    @IBAction func switchStatusChanged(_ sender: Any) {
        CategoryHelper.instance.editableCategories = !CategoryHelper.instance.editableCategories
    }
    @IBAction func fetchAccountBtnPressed(_ sender: Any) {
        let connectToSaltEdgeVC = ConnectToSaltEdgeVC()
        connectToSaltEdgeVC.modalPresentationStyle = .custom
        connectToSaltEdgeVC.delegate = self
        presentDetail(connectToSaltEdgeVC)
    }
    
    func fetchProviders(){
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        CoreDataService.instance.fetchSEProviders(ByUserID: currentUser) { (providers) in
            self.providers = providers
            if providers.count > 0 {
                updateAccountBtn.isHidden = false
                infoLbl.isHidden = false
                tableView.isHidden = false
            } else {
                updateAccountBtn.isHidden = true
                infoLbl.isHidden = true
                tableView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    @IBAction func updateAccountsBtnPressed(_ sender: Any) {
        SaltEdgeHelper.instance.fetchData()
    }
    
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell  = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
            cell.configureCell(item: providers[indexPath.row].name ?? "")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            guard let loginSecret = self.providers[indexPath.row].secret, let customerSecret = self.providers[indexPath.row].secustomer?.id else {return}
            let provider = self.providers[indexPath.row]
            if !NetworkReachabilityManager()!.isReachable {
                HUD.flash(.labeledError(title: "Error", subtitle: "There are no internet connections"), delay: 3.0)
                return
            }
            HUD.show(.labeledProgress(title: "Disabling accounts", subtitle: nil))
            SERequestManager.shared.set(appId: Constants.APP_ID_SALTEDGE, appSecret: Constants.APP_SECRET_SALTEDGE)
            SERequestManager.shared.set(customerSecret: customerSecret)
            SERequestManager.shared.removeLogin(with: loginSecret) { [weak self] response in
                switch response {
                case .success(let value):
                    if value.data.removed {
                        CoreDataService.instance.removeSEProvider(seProvider: provider)
                        self?.fetchProviders()
                    }
                    HUD.hide(animated: true)
                case .failure(let error):
                    HUD.flash(.labeledError(title: "Error", subtitle: error.localizedDescription), delay: 3.0)
                }
            }
        }
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)

        return [deleteAction]
    }
}

extension SettingsVC: SettingsProtocol{
    func update() {
        self.fetchProviders()
    }
}
