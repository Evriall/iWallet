//
//  LineChartVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/22/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import Charts

class LineChartVC: UIViewController {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var belowOptionView: UIView!
    @IBOutlet weak var optionSV: UIStackView!
    @IBOutlet weak var currencyBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var periodSV: UIStackView!
    @IBOutlet weak var periodSegmentView: UISegmentedControl!
    @IBOutlet weak var transactionTypeSegmentView: UISegmentedControl!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    @IBOutlet weak var InfoLbl: UILabel!
    
    var startDate = Date()
    var endDate = Date()
    var reportLabel = ""
    var currency = ""
    var fetchedData = [(name: String, id: String, value: Double, date: Date)]()
    var accountColors = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionTypeSegmentView.selectedSegmentIndex = 0
        periodSegmentView.selectedSegmentIndex = 0
        startDate = startDate.startOfWeek()
        endDate = endDate.endOfWeek()
        startDateBtn.layer.borderWidth = 1
        startDateBtn.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
        endDateBtn.layer.borderWidth = 1
        endDateBtn.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
        currencyBtn.layer.borderWidth = 1
        currencyBtn.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
        
        if let currentAccountObjectID = AccountHelper.instance.currentAccount, let currentUser = LoginHelper.instance.currentUser {
            CoreDataService.instance.fetchAccount(ByObjectID: currentAccountObjectID, userID: currentUser) { (account) in
                guard let account = account else {return}
                self.currency = account.currency ?? "USD"
                currencyBtn.setTitle(self.currency, for: .normal)
            }
        } else {
            currency = "USD"
        }

        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerDragEnabled = true
        
        chartView.backgroundColor = .white
        chartView.extraLeftOffset = 8.0

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        xAxis.labelTextColor = #colorLiteral(red: 0.4705882353, green: 0.662745098, blue: 0.662745098, alpha: 1)
        xAxis.avoidFirstLastClippingEnabled = true
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.labelTextColor = #colorLiteral(red: 0.4705882353, green: 0.662745098, blue: 0.662745098, alpha: 1)
        chartView.rightAxis.enabled = false
        chartView.legend.form = .line
        fetchData()
    }

    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func optionBtnPressed(_ sender: Any) {
        optionSV.isHidden = !optionSV.isHidden
        belowOptionView.isHidden = !belowOptionView.isHidden
    }
    
    @IBAction func currencyBtnPressed(_ sender: Any) {
        let selectCurrency = SelectCurrencyVC()
        selectCurrency.date = endDate
        selectCurrency.modalPresentationStyle = .custom
//        selectCurrency.pairCurrency = currency
        selectCurrency.delegate = self
        present(selectCurrency , animated: false, completion: nil)
    }
    
    @IBAction func startDateBtnPressed(_ sender: Any) {
        let calendarVC = CalendarVC()
        calendarVC.delegate = self
        calendarVC.currentDate = startDate
        calendarVC.start = true
        calendarVC.modalPresentationStyle = .custom
        presentDetail(calendarVC )
    }
    @IBAction func endDateBtnPressed(_ sender: Any) {
        let calendarVC = CalendarVC()
        calendarVC.delegate = self
        calendarVC.currentDate = endDate
        calendarVC.start = false
        calendarVC.modalPresentationStyle = .custom
        presentDetail(calendarVC )
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender == periodSegmentView {
            if sender.selectedSegmentIndex == 0 {
                startDate = Date().startOfWeek()
                endDate = Date().endOfWeek()
                periodSV.isHidden = true
            } else if sender.selectedSegmentIndex == 1{
                startDate = Date().startOfMonth()
                endDate = Date().endOfMonth()
                periodSV.isHidden = true
            } else if sender.selectedSegmentIndex == 2{
                startDate = Date().startOfYear()
                endDate = Date().endOfYear()
                periodSV.isHidden = true
            } else if sender.selectedSegmentIndex == 3{
                startDateBtn.setTitle(startDate.ChartStr(), for: .normal)
                endDateBtn.setTitle(endDate.ChartStr(), for: .normal)
                periodSV.isHidden = false
            }
        }
        fetchData()
    }
    func fetchData(){
        fetchedData = []
        guard let currentUser = LoginHelper.instance.currentUser else {return}
        reportLabel = "Account`s"
        if transactionTypeSegmentView.selectedSegmentIndex == 0 {
            reportLabel += " turnover in " + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)
            CoreDataService.instance.fetchAccountsTurnoverGroupedByDate(WithStartDate: startDate, WithEndDate: endDate, userID: currentUser) { (accountsArray) in
                if accountsArray.count == 0 {
                    InfoLbl.isHidden = false
                    chartView.isHidden = true
                } else {
                    for (index, arrayItem) in accountsArray.enumerated() {
                        if let account = arrayItem["account.name"] as? String, let accountID = arrayItem["account.id"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String, let date =  arrayItem["date"] as? Date{
                            if currency != self.currency{
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: self.currency, complition: { (rate) in
                                    let valueAtExchangeRate = sum * rate
                                    self.fetchedData.append((name: account, id: accountID, value: valueAtExchangeRate, date: date))
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                })
                            } else {
                                self.fetchedData.append((name: account, id: accountID, value: sum, date: date))
                                if index == accountsArray.count - 1 {
                                    self.setUpChart()
                                }
                            }
                        }
                    }
                }
            }
        } else if transactionTypeSegmentView.selectedSegmentIndex == 1{
            reportLabel += " income in " + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)
            CoreDataService.instance.fetchAccountsIncomeGroupedByDate(WithStartDate: startDate, WithEndDate: endDate, userID: currentUser) { (accountsArray) in
                if accountsArray.count == 0 {
                    InfoLbl.isHidden = false
                    chartView.isHidden = true
                } else {
                    for (index, arrayItem) in accountsArray.enumerated() {
                        if let account = arrayItem["account.name"] as? String, let accountID = arrayItem["account.id"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String, let date =  arrayItem["date"] as? Date{
                            if currency != self.currency{
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: self.currency, complition: { (rate) in
                                    let valueAtExchangeRate = sum * rate
                                    self.fetchedData.append((name: account, id: accountID, value: valueAtExchangeRate, date: date))
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                })
                            } else {
                                self.fetchedData.append((name: account, id: accountID, value: sum, date: date))
                                if index == accountsArray.count - 1 {
                                    self.setUpChart()
                                }
                            }
                        }
                    }
                }
            }
           
        } else {
            reportLabel += " costs in " + AccountHelper.instance.getCurrencySymbol(byCurrencyCode: currency)
            CoreDataService.instance.fetchAccountsCostsGroupedByDate(WithStartDate: startDate, WithEndDate: endDate, userID: currentUser) { (accountsArray) in
                if accountsArray.count == 0 {
                    InfoLbl.isHidden = false
                    chartView.isHidden = true
                } else {
                    for (index, arrayItem) in accountsArray.enumerated() {
                        if let account = arrayItem["account.name"] as? String, let accountID = arrayItem["account.id"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String, let date =  arrayItem["date"] as? Date{
                            if currency != self.currency{
                                ExchangeService.instance.fetchLastCurrencyRate(baseCode: currency, pairCode: self.currency, complition: { (rate) in
                                    let valueAtExchangeRate = sum * rate
                                    self.fetchedData.append((name: account,  id: accountID, value: valueAtExchangeRate, date: date))
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                })
                            } else {
                                self.fetchedData.append((name: account,  id: accountID, value: sum, date: date))
                                if index == accountsArray.count - 1 {
                                    self.setUpChart()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setUpChart(){
        titleLbl.text = reportLabel
        InfoLbl.isHidden = true
        chartView.isHidden = false
        chartView.resetZoom()
        var currentAccountName = ""
        var currentAccountID = ""
        var entries = [ChartDataEntry]()
        var sets = [LineChartDataSet]()
        var dateGrouped: Date?
        var sumByDate = 0.0
        for (index,item) in fetchedData.enumerated() {
            if currentAccountID.isEmpty {
                currentAccountName = item.name
                currentAccountID = item.id
            } else if currentAccountID != item.id {
                entries.append(ChartDataEntry(x: (dateGrouped?.timeIntervalSince1970) ?? Date().timeIntervalSince1970, y: sumByDate))
                let set = LineChartDataSet(values: entries, label: currentAccountName)
                set.colors = [accountColors[sets.count % accountColors.count]]
                set.setCircleColor(accountColors[sets.count % accountColors.count])
                sets.append(set)
                entries = []
                currentAccountName = item.name
                currentAccountID = item.id
                dateGrouped = nil
                sumByDate = 0.0
            }
            
            if dateGrouped == nil {
                dateGrouped = item.date.startOfDay()
            } else if dateGrouped != item.date.startOfDay() {
                entries.append(ChartDataEntry(x: (dateGrouped?.timeIntervalSince1970) ?? Date().timeIntervalSince1970, y: sumByDate))
                dateGrouped = item.date.startOfDay()
                sumByDate = 0.0
            }
            
            sumByDate += item.value
            
            if index == fetchedData.count - 1 {
                entries.append(ChartDataEntry(x: (dateGrouped?.timeIntervalSince1970) ?? Date().timeIntervalSince1970, y: sumByDate))
                let set = LineChartDataSet(values: entries, label: currentAccountName)
                set.colors = [accountColors[sets.count % accountColors.count]]
                set.setCircleColor(accountColors[sets.count % accountColors.count])
                sets.append(set)
            }
            
        }
        
        let data = LineChartData(dataSets: sets)
        data.setValueFont(.systemFont(ofSize: 11, weight: .medium))
        data.setValueTextColor(.black)
        chartView.data = data
    }
}

extension LineChartVC: AccountProtocol {
    func handleCurrency(_ currency: String, currencyRate: Double) {
        self.currency = currency
        currencyBtn.setTitle(currency, for: .normal)
        fetchData()
    }
    
    func handleAccountType(_ type: String) {
    }
}

extension LineChartVC: CalendarProtocol {
    func handleDate(_ date: Date, start: Bool) {
        if start {
            startDate = date
            startDateBtn.setTitle(startDate.ChartStr(), for: .normal)
        } else {
            endDate = date
            endDateBtn.setTitle(endDate.ChartStr(), for: .normal)
        }
        fetchData()
    }
}
