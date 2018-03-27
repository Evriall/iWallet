//
//  CategoryVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [Category]()
    var delegate: CategoryProtocol?
    @IBAction func openAddCategoryBtnPressed(_ sender: Any) {
        guard let  addCategoryVC = storyboard?.instantiateViewController(withIdentifier: "AddCategoryVC") else {return}
        presentDetail(addCategoryVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoreDataService.instance.fetchParents { (categories) in
            self.categories = categories
             CategoryHelper.instance.clear()
            self.tableView.reloadData()
        }
    }
}

extension CategoryVC : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell {
            cell.configureCell(category: categories[indexPath.row],showChildren: true, editable: CategoryHelper.instance.editableCategories)
            cell.openChildrenCategoriesBtn.tag = indexPath.row
            cell.openChildrenCategoriesBtn.addTarget(self, action: #selector(CategoryVC.openChildrenCategories), for: .touchUpInside)
            cell.closeChildrenCategoriesBtn.tag = indexPath.row
            cell.closeChildrenCategoriesBtn.addTarget(self, action: #selector(CategoryVC.closeChildrenCategories), for: .touchUpInside)
            cell.openCategoryForEditingBtn.tag = indexPath.row
            cell.openCategoryForEditingBtn.addTarget(self, action: #selector(CategoryVC.openCategoryForEditing), for: .touchUpInside)
            return cell
        }
        return CategoryCell()
    }
    
    @objc func openCategoryForEditing(sender: UIButton){
        let tag = sender.tag
        let category = categories[tag]
        guard let  addCategoryVC = storyboard?.instantiateViewController(withIdentifier: "AddCategoryVC") as? AddCategoryVC else {return}
        addCategoryVC.categoryItem = category
        presentDetail(addCategoryVC)
    }
    
    @objc func openChildrenCategories(sender: UIButton){
        var tag = sender.tag
        let parent = categories[tag]
        guard let name = parent.name else {return}
        CategoryHelper.instance.set(categoryName: name, isShown: true)
        CoreDataService.instance.fetchChildrenByParent(parent) { (children) in
            if children.count > 0 {
                categories.insert(contentsOf: children, at: tag + 1)
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func closeChildrenCategories(sender: UIButton){
        var tag = sender.tag
        let parent = categories[tag]
        guard let name = parent.name else {return}
        CategoryHelper.instance.set(categoryName: name, isShown: false)
        CoreDataService.instance.fetchChildrenByParent(parent) { (children) in
            if children.count > 0 {
                tag += 1
                for _ in children{
                    categories.remove(at: tag)
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CategoryHelper.instance.clear()
        dismissDetail()
        delegate?.handleCategory(categories[indexPath.row])
    }
}
