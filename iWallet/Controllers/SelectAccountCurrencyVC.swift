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
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: AccountProtocol?
    var filteredCurrency = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        
        searchBar.placeholder = "Search currency"
        searchBar.delegate = self
    }
}

extension SelectAccountCurrencyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredCurrency.count : Locale.isoCurrencyCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
            let currencyCode = selectCurrency(index: indexPath.row)
            let desc = "\(currencyCode) \(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currencyCode))"
            cell.configureCell(item: desc)
            return cell
        }
        return TypeAndCurrencyCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = isFiltering() ? filteredCurrency[indexPath.row] : Locale.isoCurrencyCodes[indexPath.row]
        delegate?.handleCarrency(currency)
        dismissDetail()
    }

    func isFiltering() -> Bool {
        guard let text = searchBar.text else {return false}
        return !text.isEmpty
    }
    
    func selectCurrency(index: Int) -> String {
        if isFiltering() {
            return filteredCurrency[index]
        } else {
            return Locale.isoCurrencyCodes[index]
        }
    }
}

extension SelectAccountCurrencyVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredCurrency = Locale.isoCurrencyCodes.filter { currency in
                return currency.lowercased().contains(searchText.lowercased())
            }
        tableView.reloadData()
        }
    }
}
