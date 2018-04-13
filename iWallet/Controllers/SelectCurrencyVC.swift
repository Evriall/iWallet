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
    var filteredCurrencies = [(code: String, rate: Double)]()
    var currencies = [(code: String, rate: Double)]()
    var date: Date = Date()
    var pairCurrency = ""
    
    func fetchCurrencyRate(baseCode: String, pairCode: String, date: Date){
        CoreDataService.instance.fetchCurrencyRate(base: baseCode, pair: pairCode, date: date) { (currencyRates) in
            if currencyRates.count > 0 {
                if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: baseCode, pair: pairCode, rates: currencyRates) {
                    self.currencies.append((code: baseCode, rate: currencyRate))
                    self.tableView.reloadData()
                } else {
                    print("Can`t evaluate currency rate for \(baseCode):\(pairCode)")
                }
            } else {
                if NetworkReachabilityManager()!.isReachable {
                    if  Date().startOfDay() <= date {
                        ExchangeService.instance.getCurrencyRateByAPILatest(complition: { (success) in
                            if success {
                                CoreDataService.instance.fetchCurrencyRate(base: baseCode, pair: pairCode, date: date) { (currencyRates) in
                                    if currencyRates.count > 0 {
                                        if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: baseCode, pair: pairCode, rates: currencyRates) {
                                            self.currencies.append((code: baseCode, rate: currencyRate))
                                            self.tableView.reloadData()
                                        } else {
                                            print("Can`t evaluate currency rate for \(baseCode):\(pairCode)")
                                        }
                                    }
                                }
                                
                            }
                        })
                    } else {
                        ExchangeService.instance.getHistoricalCurrencyRate(date: date, complition: { (success) in
                            if success {
                                CoreDataService.instance.fetchCurrencyRate(base: baseCode, pair: pairCode, date: date) { (currencyRates) in
                                    if currencyRates.count > 0 {
                                        if let currencyRate = ExchangeService.instance.evaluateCurrencyRate(base: baseCode, pair: pairCode, rates: currencyRates) {
                                            self.currencies.append((code: baseCode, rate: currencyRate))
                                            self.tableView.reloadData()
                                        } else {
                                            print("Can`t evaluate currency rate for \(baseCode):\(pairCode)")
                                        }
                                    }
                                }
                            }
                        })
                    }
                } else {
                    self.showAlert()
                }
            }
        }
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        
        searchBar.placeholder = "Search currency"
        searchBar.delegate = self
        
        CoreDataService.instance.fetchCurrenciesFromCurrencyRate { (currencies) in
            if currencies.count > 0 {
                
                for item in currencies {
                    if pairCurrency.isEmpty {
                        self.currencies.append((code: item, rate: 1.0))
                    } else {
                        fetchCurrencyRate(baseCode: item, pairCode: pairCurrency, date: date)
                    }
                }
            } else {
                if NetworkReachabilityManager()!.isReachable {
                    ExchangeService.instance.getCurrencyRateByAPILatest(complition: { (success) in
                        if success {
                            CoreDataService.instance.fetchCurrenciesFromCurrencyRate(complition: { (currencies) in
                                for item in currencies {
                                    if self.pairCurrency.isEmpty {
                                        self.currencies.append((code: item, rate: 1.0))
                                    } else {
                                        self.fetchCurrencyRate(baseCode: item, pairCode: self.pairCurrency, date: self.date)
                                    }
                                }
                            })
                        }
                    })
                } else {
                    showAlert()
                }
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
        delegate?.handleCarrency(currency.code, currencyRate: currency.rate)
        dismissDetail()
    }

    func isFiltering() -> Bool {
        guard let text = searchBar.text else {return false}
        return !text.isEmpty
    }
    
    func selectCurrency(index: Int) -> (code: String, rate: Double) {
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
                return currency.code.lowercased().contains(searchText.lowercased())
            }
        tableView.reloadData()
        }
    }
}
