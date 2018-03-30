//
//  SelectAccountCurrencyVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SelectAccountCurrencyVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    
    var delegate: AccountProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
    }
}

extension SelectAccountCurrencyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Locale.isoCurrencyCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
            let desc = "\(Locale.isoCurrencyCodes[indexPath.row]) \(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: Locale.isoCurrencyCodes[indexPath.row]))"
            cell.configureCell(item: desc)
            return cell
        }
        return TypeAndCurrencyCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.handleCarrency(Locale.isoCurrencyCodes[indexPath.row])
        dismissDetail()
    }
}
