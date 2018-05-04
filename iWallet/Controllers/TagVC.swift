//
//  TagVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/2/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class Detail {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class AccountDetail: Detail {
    var amount: Double = 0.0
    override init(name: String) {
        super.init(name: name)
    }
    init(name: String, amount: Double) {
        self.amount = amount
        super.init(name: name)
    }
    
}
class DateDetail: AccountDetail {
    
}

class TransactionDetail: AccountDetail {
    var description: String
    init(name: String, amount: Double, description: String) {
        self.description = description
        super.init(name: name, amount: amount)
        
    }
}

class TagVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var menuBtn: UIButton!
    var tags = [String]()
    var tagsTableView: UITableView?
    var tagsView: UIView?
    var tagTextField: UITextField?
    var details = [Detail]()
    var accounts = [AccountDetail]()
    var dates = [[DateDetail]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddTransactionVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        tagsView = UIView(frame: CGRect(x: 32.0, y: 30.0 + 77.0, width: self.view.frame.width - 64.0, height: 0.0))
        tagsView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tagsTableView = UITableView(frame: CGRect(x: -8.0, y: 0.0, width: (tagsView?.frame.width)! - 40.0, height: 0.0))
        tagsTableView?.dataSource = self
        tagsTableView?.delegate = self
        tagsTableView?.rowHeight = 60
        tagsTableView?.separatorStyle = .none
        tagsTableView?.sectionIndexColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        tagsTableView?.register(UINib(nibName: "TypeAndCurrencyCell", bundle: nil), forCellReuseIdentifier: "TypeAndCurrencyCell")
        tagsView?.addSubview(tagsTableView!)
        tagsView?.isHidden = true
        tagTextField = UITextField(frame: CGRect(x: 40.0, y: 0.0, width: tableView.frame.width, height: 30.0))
        tagTextField?.delegate = self
        tagTextField?.font = UIFont(name: "Avenir-Heavy", size: 20.0)
        tagTextField?.placeholder = "Search"
        tagTextField?.addTarget(self, action: #selector(TagVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        let searchGlassImageView = UIImageView(frame: CGRect(x: 8.0, y: 3.0, width: 24.0, height: 24.0))
        searchGlassImageView.image = UIImage(named: "searchIconDark")
        headerView.addSubview(tagTextField!)
        headerView.addSubview(searchGlassImageView)
        tableView.tableHeaderView = headerView
        tableView.delegate = self
        tableView.dataSource = self
        tableView?.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        self.view.addSubview(tagsView!)
        details.append(AccountDetail(name: "Privat", amount: 1000.0))
        details.append(AccountDetail(name: "Aval", amount: 2000.0))
        
    }
    
    func fetchTags(){
        if let tag = tagTextField?.text, !tag.isEmpty {
            CoreDataService.instance.fetchPopularTagsName(ByStr: tag) { (tags) in
                self.tags = tags
                setTagsTableViewHeight()
                tagsTableView?.reloadData()
            }
        } else {
            tags = []
            setTagsTableViewHeight()
            tagsTableView?.reloadData()
        }
    }
    @objc func textFieldDidChange(){
        fetchTags()
    }
    func setTagsTableViewHeight(){
        let height = CGFloat(tags.count * 60)
        tagsView?.frame = CGRect(x: 32.0, y: 30.0 + 77.0, width: self.view.frame.width - 64.0, height: height >= self.view.frame.size.height ? self.view.frame.size.height - (60 + 77 + 30): height)
        tagsTableView?.frame = CGRect(x: -8.0, y: 0.0, width: (tagsView?.frame.width)! - 8.0, height: height >= self.view.frame.size.height ? self.view.frame.size.height - (60 + 77 + 30): height)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
        tagsView?.isHidden = true
    }
}
extension TagVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fetchTags()
        tagsView?.isHidden = false
        
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
            return tags.count
        } else {
            return details.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tagsTableView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TypeAndCurrencyCell", for: indexPath) as? TypeAndCurrencyCell {
                cell.configureCell(item: tags[indexPath.row])
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
            
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tagsTableView {
            tagsView?.isHidden = true
            tableView.deselectRow(at: indexPath, animated: false)
            tagTextField?.text = tags[indexPath.row]
        } else {
            tagsView?.isHidden = true
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            if details[indexPath.row] is AccountDetail || details[indexPath.row] is DateDetail {
                return 30.0
            }
        }
        return 44.0
    }
    
}
