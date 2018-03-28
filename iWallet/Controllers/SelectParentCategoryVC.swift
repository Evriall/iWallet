//
//  SelectParentCategoryVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/26/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class SelectParentCategoryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: CategoryProtocol?
    var parentCategories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
         tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        CoreDataService.instance.fetchParents { (parentCategories) in
            self.parentCategories = parentCategories
        }
    }
    
    @objc func handleTap(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension SelectParentCategoryVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parentCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
            cell.configureCell(category: parentCategories[indexPath.row], showChildren: false)
            return cell
        }
        return CategoryCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.handleCategory(parentCategories[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
