//
//  AddCategoryVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddCategoryVC: UIViewController {
    var categoryParent: Category?
    
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
        saveCategoryBtn.bindToKeyBoard()
        saveCategoryBtn.isEnabled = false
        saveCategoryBtn.setDeselectedColor()
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    @IBAction func saveCategoryBtnPressed(_ sender: Any) {
        guard let text = categoryNameTxt.text else {return}
        CoreDataService.instance.saveCategory(name: text, color: categoryImg.backgroundColor, parent: categoryParent) { (success) in
            if success {
                dismissDetail()
            }
        }
    }
    @IBAction func categoryParentBtnPressed(_ sender: Any) {
    }
    
    @objc func textFieldDidChange() {
        guard let text = categoryNameTxt.text else {return}
        if text.isEmpty {
            saveCategoryBtn.isEnabled = false
            saveCategoryBtn.setDeselectedColor()
        } else {
            saveCategoryBtn.isEnabled = true
            saveCategoryBtn.setSelectedColor()
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
