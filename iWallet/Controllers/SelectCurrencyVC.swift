//
//  SelectAccountCurrencyVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/30/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import Alamofire

class SelectCurrencyVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: AccountProtocol?
    var filteredCurrencies = [(code: String, name: String, rate: Double)]()
    var currencies = [(code: String, name: String, rate: Double)]()
    var date = Date()
    var pairCurrency = ""
    
    func fetchCurrenciesRate(currencies: [String]){
        let dateToFetch = date >= Date().startOfDay() ? Date().startOfDay() : date
        var flagNotFetchedCurrencyRate = currencies.count == 0 ? true:  false
        for currency in currencies {
            if !fetchCurrencyRate(baseCode: currency, pairCode: pairCurrency, date: dateToFetch) {
                flagNotFetchedCurrencyRate = true
                self.currencies = []
                break
            }
        }
        if flagNotFetchedCurrencyRate {
            if NetworkReachabilityManager()!.isReachable {
                if  Date().startOfDay() == dateToFetch {
                    ExchangeService.instance.getCurrencyRateByAPILatest(complition: { (success) in
                        if success {
                            CoreDataService.instance.fetchCurrenciesFromCurrencyRate(complition: { (fetchedCurrencies) in
                                for currency in fetchedCurrencies {
                                    if self.pairCurrency.isEmpty {
                                        self.currencies.append((code: currency, name: Locale.current.localizedString(forCurrencyCode: currency) ?? currency, rate: 1.0))
                                    } else {
                                        self.fetchCurrencyRate(baseCode: currency, pairCode: self.pairCurrency, date: dateToFetch)
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    })
                } else {
                    ExchangeService.instance.getHistoricalCurrencyRate(date: date, complition: { (success) in
                        if success {
                            CoreDataService.instance.fetchCurrenciesFromCurrencyRate(complition: { (fetchedCurrencies) in
                                for currency in fetchedCurrencies {
                                    if self.pairCurrency.isEmpty {
                                        self.currencies.append((code: currency, name: Locale.current.localizedString(forCurrencyCode: currency) ?? currency, rate: 1.0))
                                    } else {
                                        self.fetchCurrencyRate(baseCode: currency, pairCode: self.pairCurrency, date: dateToFetch)
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    })
                }
            } else {
                self.showAlert()
            }
        }
        self.tableView.reloadData()
    }
    
    func fetchCurrencyRate(baseCode: String, pairCode: String, date: Date) -> (Bool){
        var flag = false
        CoreDataService.instance.fetchCurrencyRate(base: baseCode, pair: pairCode, date: date) { (currencyRates) in
            if currencyRates.count > 0 {
                if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: baseCode, pair: pairCode, rates: currencyRates) {
                    self.currencies.append((code: baseCode,name: Locale.current.localizedString(forCurrencyCode: baseCode) ?? "", rate: currencyRate))
                    flag = true
                } else {
                    debugPrint("Can`t evaluate currency rate for \(baseCode):\(pairCode)")
                }
            } else {
                flag = false
            }
        }
        return flag
    }
    
    func showAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "There are no internet connection", message: "Can`t load currency rates", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.dismissDetail()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(SelectCurrencyVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        
        searchBar.placeholder = "Search currency"
        searchBar.delegate = self
        
        CoreDataService.instance.fetchCurrenciesFromCurrencyRate { (currencies) in
            if currencies.count == 0 {
                fetchCurrenciesRate(currencies: currencies)
            } else {
                if pairCurrency.isEmpty {
                    for item in currencies {
                        self.currencies.append((code: item, name: Locale.current.localizedString(forCurrencyCode: item) ?? item, rate: 1.0))
                    }
                } else {
                    fetchCurrenciesRate(currencies: currencies)
                }
            }
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @objc func handleTap(){
//        dismissDetail()
        dismiss(animated: true, completion: nil)
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
            let currency = selectCurrency(index: indexPath.row)
            if pairCurrency.isEmpty {
                cell.configureCell(pairCode: currency.code)
                return cell
            } else {
                let transormedValue = EncodeDecodeService.instance.transformCurrencyRate(value: currency.rate)
                let currencyRateDesc = "\(transormedValue.multiplier)\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency.code)) = \(transormedValue.newValue.roundTo(places: 2))\(AccountHelper.instance.getCurrencySymbol(byCurrencyCode: pairCurrency))"
                cell.configureCell(pairCode: currency.code, currencyRate: currencyRateDesc)
                return cell
            }
        }
        return TypeAndCurrencyCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = selectCurrency(index: indexPath.row)
        delegate?.handleCurrency(currency.code, currencyRate: currency.rate)
//        dismissDetail()
        dismiss(animated: true, completion: nil)
    }

    func isFiltering() -> Bool {
        guard let text = searchBar.text else {return false}
        return !text.isEmpty
    }
    
    func selectCurrency(index: Int) -> (code: String, name: String, rate: Double) {
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
                return currency.code.lowercased().contains(searchText.lowercased()) || currency.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
