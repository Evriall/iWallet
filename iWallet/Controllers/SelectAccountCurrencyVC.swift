//
//  SelectAccountCurrencyVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SelectCurrencyVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: AccountProtocol?
    var filteredCurrencies = [String]()
    var currencies = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        
        searchBar.placeholder = "Search currency"
        searchBar.delegate = self
        
        CoreDataService.instance.fetchCurrenciesFromCurrencyRate { (currencies) in
            if currencies.count > 0 {
                self.currencies = currencies
            } else {
                ExchangeService.instance.getCurrencyRateByAPILatest(complition: { (success) in
                    if success {
                        CoreDataService.instance.fetchCurrenciesFromCurrencyRate(complition: { (currencies) in
                            self.currencies = currencies
                        })
                    }
                })
            }
        }
    }
}

extension SelectCurrencyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredCurrencies.count : currencies.count
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
        let currency = isFiltering() ? filteredCurrencies[indexPath.row] : currencies[indexPath.row]
        delegate?.handleCarrency(currency)
        dismissDetail()
    }

    func isFiltering() -> Bool {
        guard let text = searchBar.text else {return false}
        return !text.isEmpty
    }
    
    func selectCurrency(index: Int) -> String {
        if isFiltering() {
            return filteredCurrencies[index]
        } else {
            return currencies[index]
        }
    }
}

extension SelectCurrencyVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredCurrencies = currencies.filter { currency in
                return currency.lowercased().contains(searchText.lowercased())
            }
        tableView.reloadData()
        }
    }
}
