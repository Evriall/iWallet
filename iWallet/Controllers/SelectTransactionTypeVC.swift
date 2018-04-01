//
//  SelectTransactionTypeVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/1/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SelectTransactionTypeVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var delegate: TransactionProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
    }
    
    func setUpUIElements(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
    }

}

extension SelectTransactionTypeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransactionType.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
            cell.configureCell(item: TransactionType.allValues[indexPath.row].rawValue)
            return cell
        }
        return TypeAndCurrencyCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = TransactionType.allValues[indexPath.row].rawValue
        delegate?.handleTransactionType(type)
        dismissDetail()
    }
}
