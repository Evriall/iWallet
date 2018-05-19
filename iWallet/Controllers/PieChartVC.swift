//
//  PieChartVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/18/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import Charts

class PieChartVC: UIViewController {
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var optionSV: UIStackView!
    @IBOutlet weak var periodSV: UIStackView!
    @IBOutlet weak var periodSegmentView: UISegmentedControl!
    @IBOutlet weak var transactionTypeSegmentView: UISegmentedControl!
    @IBOutlet weak var reportTypeSegmentView: UISegmentedControl!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    @IBOutlet weak var belowOptionView: UIView!
    @IBOutlet weak var InfoLbl: UILabel!
    
    var startDate = Date()
    var endDate = Date()
    var fetchedData = [(name: String, value: Double, color: UIColor)]()
    var totalSum = 0.0
    var entries = [PieChartDataEntry]()
    var colors = [UIColor]()
    var accountColors = [#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), #colorLiteral(red: 1, green: 0.7843137255, blue: 0, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)]
    var reportLabel = ""
    override func viewDidLoad() {
        super.viewDidLoad()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchVC.handleTap))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
        reportTypeSegmentView.selectedSegmentIndex = 0
        transactionTypeSegmentView.selectedSegmentIndex = 0
        periodSegmentView.selectedSegmentIndex = 0
        startDate = startDate.startOfWeek()
        endDate = endDate.endOfWeek()
        startDateBtn.layer.borderWidth = 1
        startDateBtn.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
        endDateBtn.layer.borderWidth = 1
        endDateBtn.layer.borderColor = #colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1)
        chartView.drawHoleEnabled = false
        fetchData()
    }
    
//    @objc func handleTap(){
//        if !optionSV.isHidden {
//            optionSV.isHidden = true
//            belowOptionView.isHidden = true
//        }
//    }
    
    func fetchData() {
        fetchedData = []
        entries = []
        colors = []
        totalSum = 0.0
        if reportTypeSegmentView.selectedSegmentIndex == 0{
            reportLabel = "Account`s"
            if transactionTypeSegmentView.selectedSegmentIndex == 0 {
                reportLabel += " turnover"
                CoreDataService.instance.fetchAccountsTurnover(WithStartDate: startDate, WithEndDate: endDate) { (accountsArray) in
                    if accountsArray.count == 0 {
                        InfoLbl.isHidden = false
                        chartView.isHidden = true
                    } else {
                        for (index, arrayItem) in accountsArray.enumerated() {
                            if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String{
                                if currency != "USD"{
                                    ExchangeService.instance.fetchLastCurrencyRate(baseCode: "USD", pairCode: currency, complition: { (rate) in
                                        let valueAtExchangeRate = sum * rate
                                        self.totalSum += valueAtExchangeRate
                                        self.fetchedData.append((name: account, value: valueAtExchangeRate, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                        if index == accountsArray.count - 1 {
                                            self.setUpChart()
                                        }
                                    })
                                } else {
                                    self.fetchedData.append((name: account, value: sum, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    totalSum += sum
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                }
                            }
                        }
                    }
                }
            } else if transactionTypeSegmentView.selectedSegmentIndex == 1{
                reportLabel += " income"
                CoreDataService.instance.fetchAccountsIncome(WithStartDate: startDate, WithEndDate: endDate) { (accountsArray) in
                    if accountsArray.count == 0 {
                        InfoLbl.isHidden = false
                        chartView.isHidden = true
                    } else {
                        for (index, arrayItem) in accountsArray.enumerated() {
                            if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String{
                                if currency != "USD"{
                                    ExchangeService.instance.fetchLastCurrencyRate(baseCode: "USD", pairCode: currency, complition: { (rate) in
                                        let valueAtExchangeRate = sum * rate
                                        self.totalSum += valueAtExchangeRate
                                        self.fetchedData.append((name: account, value: valueAtExchangeRate, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                        if index == accountsArray.count - 1 {
                                            self.setUpChart()
                                        }
                                    })
                                } else {
                                    self.fetchedData.append((name: account, value: sum, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    totalSum += sum
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                reportLabel += " costs"
                CoreDataService.instance.fetchAccountsCosts(WithStartDate: startDate, WithEndDate: endDate) { (accountsArray) in
                    if accountsArray.count == 0 {
                        InfoLbl.isHidden = false
                        chartView.isHidden = true
                    } else {
                        for (index, arrayItem) in accountsArray.enumerated() {
                            if let account = arrayItem["account.name"] as? String, let sum = arrayItem["sum"] as? Double, let currency =  arrayItem["account.currency"] as? String{
                                if currency != "USD"{
                                    ExchangeService.instance.fetchLastCurrencyRate(baseCode: "USD", pairCode: currency, complition: { (rate) in
                                        let valueAtExchangeRate = sum * rate
                                        self.totalSum += valueAtExchangeRate
                                        self.fetchedData.append((name: account, value: valueAtExchangeRate, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                        if index == accountsArray.count - 1 {
                                            self.setUpChart()
                                        }
                                    })
                                } else {
                                    self.fetchedData.append((name: account, value: sum, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    totalSum += sum
                                    if index == accountsArray.count - 1 {
                                        self.setUpChart()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
           reportLabel = "Category`s"
        }
    }
    
    func setUpChart(){
        InfoLbl.isHidden = true
        chartView.isHidden = false
        fetchedData.sort { (arg0, arg1) -> Bool in
            arg0.value > arg1.value
        }
        for (index,item) in fetchedData.enumerated() {
            entries.append(PieChartDataEntry(value: ((item.value / totalSum ) * 100).roundTo(places: 2), label: item.name))
            if item.color == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
                colors.append(self.accountColors[index % self.accountColors.count])
            } else {
                colors.append(item.color)
            }
        }
        
        let set = PieChartDataSet(values: entries, label: reportLabel)
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        
        set.colors = colors
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .medium))
        data.setValueTextColor(.white)
        chartView.data = data
        chartView.chartDescription?.text = ""
        chartView.highlightValues(nil)
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
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    @IBAction func optionBtnPressed(_ sender: Any) {
        optionSV.isHidden = !optionSV.isHidden
        belowOptionView.isHidden = !belowOptionView.isHidden
    }
    
}

extension PieChartVC: CalendarProtocol {
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
