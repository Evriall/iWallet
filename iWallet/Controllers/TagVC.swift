//
//  TagVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/2/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class Detail {
}

class AccountDetail: Detail {
    var amount: Double = 0.0
    var name: String
    init(name: String) {
        self.name = name
    }
    convenience init(name: String, amount: Double) {
        self.init(name: name)
        self.amount = amount
    }
    
}
class DateDetail: AccountDetail {
    
}

class TransactionDetail: Detail {
    var transaction: Transaction
    init(transaction: Transaction) {
        self.transaction = transaction
    }
}

class TagVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var menuBtn: UIButton!
    var searchKeys = [String]()
    var tagsTableView: UITableView?
    var tagSC: UISegmentedControl?
    var tagsView: UIView?
    var searchTextField: UITextField?
    var details = [Detail]()
    var accounts = [AccountDetail]()
    var dates = [[DateDetail]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(TagVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 61.0))
        let separatorView = UIView(frame: CGRect(x: 0.0, y: 60.0, width: tableView.frame.width, height: 1.0))
        separatorView.backgroundColor = #colorLiteral(red: 0.7529411765, green: 0.7529411765, blue: 0.7529411765, alpha: 1)
        tagsView = UIView(frame: CGRect(x: 32.0, y: 30.0 + 77.0, width: self.view.frame.width - 64.0, height: 0.0))
        tagsView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tagsTableView = UITableView(frame: CGRect(x: -8.0, y: 0.0, width: (tagsView?.frame.width)! - 40.0, height: 0.0))
        tagsTableView?.dataSource = self
        tagsTableView?.delegate = self
        tagsTableView?.rowHeight = 60
        tagsTableView?.separatorStyle = .none
        tagsTableView?.sectionIndexColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        tagsTableView?.isScrollEnabled = false
        tagsTableView?.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        tagsView?.addSubview(tagsTableView!)
        tagsView?.isHidden = true
        
        tagSC = UISegmentedControl(items: ["TAG","DESCRIPTION"])
        tagSC?.selectedSegmentIndex = 0
        tagSC?.tintColor = #colorLiteral(red: 0, green: 0.568627451, blue: 0.5764705882, alpha: 1)
        tagSC?.addTarget(self, action: #selector(TagVC.handleSegmentChanged), for: .valueChanged)
        tagSC?.frame = CGRect(x: -4.0, y: 0.0, width: tableView.frame.width + 8, height: 30.0)
        
        searchTextField = UITextField(frame: CGRect(x: 40.0, y: 30.0, width: tableView.frame.width - 64, height: 30.0))
        searchTextField?.delegate = self
        searchTextField?.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        searchTextField?.placeholder = "TAG"
        searchTextField?.addTarget(self, action: #selector(TagVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        let closeBtn = UIButton(frame: CGRect(x: headerView.frame.width - 26.0, y: 36.0, width: 18.0, height: 18.0))
        closeBtn.addTarget(self, action: #selector(TagVC.closeBtnPressed), for: .touchUpInside)
        closeBtn.setTitle("", for: .normal)
        closeBtn.setImage(UIImage(named: "CloseTagGrey"), for: .normal)
        let searchGlassImageView = UIImageView(frame: CGRect(x: 8.0, y: 36.0, width: 18.0, height: 18.0))
        searchGlassImageView.image = UIImage(named: "searchIconDark")
        headerView.addSubview(closeBtn)
        headerView.addSubview(tagSC!)
        headerView.addSubview(searchTextField!)
        headerView.addSubview(searchGlassImageView)
        headerView.addSubview(separatorView)
        tableView.tableHeaderView = headerView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView?.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        self.view.addSubview(tagsView!)
        details.append(AccountDetail(name: "Privat", amount: 1000.0))
        details.append(AccountDetail(name: "Aval", amount: 2000.0))
        
    }
    
    @objc func closeBtnPressed() {
        details = []
        searchKeys = []
        searchTextField?.text = ""
        tagsView?.isHidden = true
        tagsTableView?.reloadData()
        tableView.reloadData()
    }
    @objc func handleSegmentChanged(){
        if tagSC?.selectedSegmentIndex == 0 {
            fetchTags()
             searchTextField?.placeholder = "TAG"
        } else if tagSC?.selectedSegmentIndex == 1 {
            fetchDescripitions()
             searchTextField?.placeholder = "DESCRIPTION"
        }
        details = []
        tableView.reloadData()
    }
    
    func fetchTags(){
        if let tag = searchTextField?.text, !tag.isEmpty {
            CoreDataService.instance.fetchPopularTagsName(ByStr: tag) { (tags) in
                self.searchKeys = tags
                setSearchTableViewHeight()
                tagsTableView?.reloadData()
            }
        } else {
            searchKeys = []
            setSearchTableViewHeight()
            tagsTableView?.reloadData()
        }
    }
    
    func fetchTransactionsByDescription(description: String){
        details = []
        if !description.isEmpty {
            CoreDataService.instance.fetchTransactions(ByDescription: description) { (transactions) in
                for item in transactions {
                    details.append(TransactionDetail(transaction: item))
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    func fetchDescripitions(){
        if let tag = searchTextField?.text, !tag.isEmpty {
            CoreDataService.instance.fetchTransactionsDescriptions(ByStr: tag) { (desc) in
                self.searchKeys = desc
                setSearchTableViewHeight()
                tagsTableView?.reloadData()
            }
        } else {
            searchKeys = []
            setSearchTableViewHeight()
            tagsTableView?.reloadData()
        }
    }
    
    @objc func textFieldDidChange(){
        if tagSC?.selectedSegmentIndex == 0 {
            fetchTags()
        } else {
            fetchDescripitions()
        }
    }
    func setSearchTableViewHeight(){
        let height = CGFloat(searchKeys.count * 44)
        tagsView?.frame = CGRect(x: 32.0, y: 30.0 + 30.0 + 77.0, width: self.view.frame.width - 64.0, height: height >= self.view.frame.size.height ? self.view.frame.size.height - (60 + 77 + 30): height)
        tagsTableView?.frame = CGRect(x: -8.0, y: 0.0, width: (tagsView?.frame.width)! - 8.0, height: height >= self.view.frame.size.height ? self.view.frame.size.height - (60 + 77 + 30): height)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
        tagsView?.isHidden = true
    }
}
extension TagVC: BriefProtocol {
    func handleTransaction() {
        if tagSC?.selectedSegmentIndex == 1 {
            if searchKeys.count > 0 {
                fetchTransactionsByDescription(description: searchKeys[0])
            }
        }
    }
    
    
}

extension TagVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if tagSC?.selectedSegmentIndex == 0 {
            if searchKeys.count > 0 {
                searchTextField?.text = searchKeys[0]
            }
        } else {
            if searchKeys.count > 0 {
                searchTextField?.text = searchKeys[0]
                fetchTransactionsByDescription(description: searchKeys[0])
            }
        }
        tagsView?.isHidden = true
        self.view.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tagsView?.isHidden = false
        if tagSC?.selectedSegmentIndex == 0 {
            fetchTags()
        } else {
            fetchDescripitions()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        tagsView?.isHidden = true
    }
}


extension TagVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagsTableView {
            return searchKeys.count
        } else {
            return details.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tagsTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
                cell.configureCell(item: searchKeys[indexPath.row])
                return cell
            }
        } else {
            if let detail = details[indexPath.row] as? AccountDetail {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(name: detail.name, amount: "\(detail.amount)", dark: true)
                    return cell
                }
            }
            if let detail = details[indexPath.row] as? DateDetail {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(name: detail.name, amount: "\(detail.amount)", dark: false)
                    return cell
                }
            }
            
            if let detail = details[indexPath.row] as? TransactionDetail{
                if let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell {
                    cell.configureCell(transaction: detail.transaction)
                    return cell
                }
            }
            
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tagsTableView {
            tagsView?.isHidden = true
            tableView.deselectRow(at: indexPath, animated: false)
            searchTextField?.text = searchKeys[indexPath.row]
            fetchTransactionsByDescription(description: searchKeys[indexPath.row])
        } else {
            tagsView?.isHidden = true
            if let detail  = details[indexPath.row] as? TransactionDetail {
                let addTransaction = AddTransactionVC()
                addTransaction.delegate = self
                addTransaction.transaction = detail.transaction
                addTransaction.modalPresentationStyle = .custom
                presentDetail(addTransaction)
                
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            if details[indexPath.row] is AccountDetail || details[indexPath.row] is DateDetail {
                return 30.0
            } else {
                if let detail = details[indexPath.row] as? TransactionDetail {
                    if TransactionHelper.instance.getTransactionDescription(transaction: detail.transaction).isEmpty {
                        return 30.0
                    } else {
                        return 50.0
                    }
                }
            }
        }
        return 44.0
    }
    
}
