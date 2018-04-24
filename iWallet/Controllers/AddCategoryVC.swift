//
//  AddCategoryVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddCategoryVC: UIViewController {
    var categoryParent: Category? {
        didSet {
           categoryParentBtn.setTitle(categoryParent?.name, for: .normal)
        }
    }
    var categoryItem: Category?
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryNameTxt: UITextField!
    @IBOutlet weak var categoryParentBtn: UIButton!
    
    @IBOutlet weak var saveCategoryBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        categoryNameTxt.addTarget(self, action: #selector(AddCategoryVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        categoryNameTxt.delegate = self
        if let category = categoryItem {
            categoryNameTxt.text = category.name
            if let parent = category.parent {
                categoryParent = parent
            } else {
                categoryParentBtn.isEnabled = false
            }
            categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: category.color)
            collectionView.isHidden = true
        }
        saveCategoryBtn.isEnabled = false
    }
    
    @objc func handleTap() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    @IBAction func saveCategoryBtnPressed(_ sender: Any) {
        guard let text = categoryNameTxt.text else {return}
        if !text.isEmpty {
            if let category = categoryItem {
                category.name = text
                category.color = EncodeDecodeService.instance.fromUIColorToStr(color: categoryImg.backgroundColor)
                category.parent = categoryParent
                CoreDataService.instance.update(complition: { (success) in
                    if success {
                      dismissDetail()
                    }
                })
            } else {
                CoreDataService.instance.saveCategory(name: text, color: categoryImg.backgroundColor, parent: categoryParent) { (success) in
                    if success {
                        dismissDetail()
                    }
                }
            }
        }
    }
    @IBAction func categoryParentBtnPressed(_ sender: Any) {
        CoreDataService.instance.fetchCategoryParents { (categories) in
            if categories.count > 0 {
                let selectCategory = SelectParentCategoryVC()
                selectCategory.delegate = self
                selectCategory.modalPresentationStyle = .custom
                present(selectCategory, animated: true, completion: nil)
            }
        }
    }
    
    @objc func textFieldDidChange() {
        guard let text = categoryNameTxt.text else {return}
        if text.isEmpty {
            saveCategoryBtn.isEnabled = false
        } else {
            saveCategoryBtn.isEnabled = true
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismissDetail()
    }
}

extension AddCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell {
            cell.configure(color: Constants.colors[indexPath.row])
            return cell
        }
        return ColorCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categoryImg.backgroundColor = Constants.colors[indexPath.row]
    }
  
}

extension AddCategoryVC: CategoryProtocol, UITextFieldDelegate {
    func handleCategory(_ category: Category) {
        categoryParent = category
        categoryImg.backgroundColor = EncodeDecodeService.instance.returnUIColor(components: categoryParent?.color)
        collectionView.isHidden = true
        if let text = categoryNameTxt.text, text != ""{
            saveCategoryBtn.isEnabled = true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
