//
//  AddTransactionAdditionalVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/14/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class AddTransactionAdditionalVC: UIViewController {
    @IBOutlet weak var yesterdayBtn: UIButton!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var otherDateBtn: UIButton!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var selectPlaceBtn: UIButton!
    
    var rootViewController: AddTransactionVC?
    var delegate: TransactionProtocol?
    var addTransactionVC: AddTransactionVC?
    var place: Place?
    var transaction: Transaction?
    var tagsCollectionView: UICollectionView?
    var tagTxt =  UITextField()
    let tagImageView = UIImageView(image: UIImage(named: "TagIconGrey"))
    let layoutCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    let layoutPCV: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var placeholderLabel : UILabel?
    var date = Date()
    var desc = ""
    var tags = [(name: String, selected: Bool)]()
    var photos = [[String: UIImage]]()
    var amount = 0.0
    
    func getTagsWith() -> CGFloat{
        var width = CGFloat(0)
        for item in tags {
            width += item.name.estimatedFrameForText(maxFrameWidth: scrollView.frame.width).width + 32
        }
        return width
    }
    
    func rebuildTagsUIElements(){
        let contentWidth = getTagsWith()
        tagsCollectionView?.frame = CGRect(x: 0, y: 3, width: contentWidth, height: 24)
        tagsCollectionView?.reloadData()
        tagTxt.frame = CGRect(x: contentWidth, y: (tagTxt.frame.origin.y), width: contentWidth > (0.5*scrollView.frame.width) ? (0.5*scrollView.frame.width): scrollView.frame.width - contentWidth, height: 24)
        scrollView.contentSize = CGSize(width: contentWidth + tagTxt.frame.width, height: 30)
        tagTxt.becomeFirstResponder()
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddTransactionAdditionalVC.handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
       setUpView()
    }
//    override func loadViewIfNeeded() {
////        setUpView()
//    }
    func setUpView(){
                descriptionTV.text = desc
                descriptionTV.delegate = self
                placeholderLabel = UILabel()
                placeholderLabel?.text = "Description"
                placeholderLabel?.font = UIFont(name: (descriptionTV.font?.fontName)!, size: (descriptionTV.font?.pointSize)!)
                placeholderLabel?.sizeToFit()
                descriptionTV.addSubview(placeholderLabel!)
                placeholderLabel?.frame.origin = CGPoint(x: 0, y: (descriptionTV.font?.pointSize)! / 2)
                placeholderLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                placeholderLabel?.isHidden = !descriptionTV.text.isEmpty
        
        
                if date.startOfDay() == Date().startOfDay() {
                    setToday()
                } else if date.startOfDay() == (Date() - 86400).startOfDay() {
                    setYesterday()
                } else {
                    setOtherDay()
                    otherDateBtn.setTitle(date.formatDateToStr(), for: .normal)
                }
        
                let contentWidth = getTagsWith()
                tagsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 3, width: contentWidth, height: 24), collectionViewLayout: layoutCV)
                tagsCollectionView?.dataSource = self
                tagsCollectionView?.delegate = self
                tagsCollectionView?.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
                tagsCollectionView?.showsVerticalScrollIndicator = false
                tagsCollectionView?.showsHorizontalScrollIndicator = false
                tagsCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
                tagImageView.frame = CGRect(x: 4, y: 3, width: 32, height: 24)
                tagTxt.frame = CGRect(x: contentWidth, y: 3, width: contentWidth > (0.5*scrollView.frame.width) ? (0.5*scrollView.frame.width): scrollView.frame.width - contentWidth, height: 24)
                tagTxt.returnKeyType = .done
                tagTxt.leftView = tagImageView
                tagTxt.leftViewMode = .unlessEditing
                tagTxt.delegate = self
                scrollView.delegate = self
                scrollView.contentSize = CGSize(width: contentWidth + tagTxt.frame.width, height: 30)
                scrollView.addSubview(tagsCollectionView!)
                scrollView.addSubview(tagTxt)
        
                layoutCV.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                layoutCV.minimumInteritemSpacing = 8
                layoutCV.minimumLineSpacing = 8
        
                layoutPCV.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                layoutPCV.itemSize = CGSize(width: 100, height: 100)
                layoutPCV.minimumInteritemSpacing = 10
                layoutPCV.minimumLineSpacing = 10
        
        
                photosCollectionView?.delegate = self
                photosCollectionView?.dataSource = self
                photosCollectionView?.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
                photosCollectionView?.showsVerticalScrollIndicator = false
                photosCollectionView?.showsHorizontalScrollIndicator = false
        
                selectPlaceBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                selectPlaceBtn.setTitle(self.place?.name ?? "Select place" , for: .normal)
            }
    
//    func setUpView(addTransactionVC: AddTransactionVC, delegate: TransactionProtocol, amount: Double, place: Place?, desc: String, date: Date, tags: [(name: String, selected: Bool)], photos: [[String : UIImage]]){
//        self.amount = amount
//        self.place = place
//        self.date = date
//        self.tags = tags
//        self.photos = photos
//        self.delegate = delegate
//        self.addTransactionVC = addTransactionVC
//
//        descriptionTV.text = desc
//        descriptionTV.delegate = self
//        placeholderLabel = UILabel()
//        placeholderLabel?.text = "Description"
//        placeholderLabel?.font = UIFont(name: (descriptionTV.font?.fontName)!, size: (descriptionTV.font?.pointSize)!)
//        placeholderLabel?.sizeToFit()
//        descriptionTV.addSubview(placeholderLabel!)
//        placeholderLabel?.frame.origin = CGPoint(x: 0, y: (descriptionTV.font?.pointSize)! / 2)
//        placeholderLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        placeholderLabel?.isHidden = !descriptionTV.text.isEmpty
//
//
//        if date.startOfDay() == Date().startOfDay() {
//            setToday()
//        } else if date.startOfDay() == (Date() - 86400).startOfDay() {
//            setYesterday()
//        } else {
//            setOtherDay()
//            otherDateBtn.setTitle(date.formatDateToStr(), for: .normal)
//        }
//
//        let contentWidth = getTagsWith()
//        tagsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 3, width: contentWidth, height: 24), collectionViewLayout: layoutCV)
//        tagsCollectionView?.dataSource = self
//        tagsCollectionView?.delegate = self
//        tagsCollectionView?.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
//        tagsCollectionView?.showsVerticalScrollIndicator = false
//        tagsCollectionView?.showsHorizontalScrollIndicator = false
//        tagsCollectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//
//        tagImageView.frame = CGRect(x: 4, y: 3, width: 32, height: 24)
//        tagTxt.frame = CGRect(x: contentWidth, y: 3, width: contentWidth > (0.5*scrollView.frame.width) ? (0.5*scrollView.frame.width): scrollView.frame.width - contentWidth, height: 24)
//        tagTxt.returnKeyType = .done
//        tagTxt.leftView = tagImageView
//        tagTxt.leftViewMode = .unlessEditing
//        tagTxt.delegate = self
//        scrollView.delegate = self
//        scrollView.contentSize = CGSize(width: contentWidth + tagTxt.frame.width, height: 30)
//        scrollView.addSubview(tagsCollectionView!)
//        scrollView.addSubview(tagTxt)
//
//        layoutCV.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layoutCV.minimumInteritemSpacing = 8
//        layoutCV.minimumLineSpacing = 8
//
//        layoutPCV.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layoutPCV.itemSize = CGSize(width: 100, height: 100)
//        layoutPCV.minimumInteritemSpacing = 10
//        layoutPCV.minimumLineSpacing = 10
//
//
//        photosCollectionView?.delegate = self
//        photosCollectionView?.dataSource = self
//        photosCollectionView?.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
//        photosCollectionView?.showsVerticalScrollIndicator = false
//        photosCollectionView?.showsHorizontalScrollIndicator = false
//
//        selectPlaceBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        selectPlaceBtn.setTitle(self.place?.name ?? "Select place" , for: .normal)
//    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        if amount == 0 {return}
        delegate?.handleAdditionalInfo(place: place, desc: descriptionTV.text, date: date, tags: tags, photos: photos)
        addTransactionVC?.saveTransaction()
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        dismissDetail()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        delegate?.handleAdditionalInfo(place: place, desc: descriptionTV.text, date: date, tags: tags, photos: photos)
        self.dismissDetail()
    }
    
    @IBAction func yesterdayBtnPressed(_ sender: Any) {
        setYesterday()
        date = Date() - 86400
    }
    
    @IBAction func todayBtnPressed(_ sender: Any) {
        setToday()
        date = Date()
    }
    
    @IBAction func otherDateBtnPressed(_ sender: Any) {
        let calendarVC = CalendarVC()
        calendarVC.delegate = self
        calendarVC.currentDate = date
        calendarVC.modalPresentationStyle = .custom
        presentDetail(calendarVC )
    }
    
    @IBAction func makePhotoBtnPressed(_ sender: Any) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let makePhoto = UIAlertAction(title: "Make photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let chosePhotoFromLibrary = UIAlertAction(title: "Choose from library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        menu.addAction(makePhoto)
        menu.addAction(chosePhotoFromLibrary)
        menu.addAction(cancel)
        self.present(menu, animated: true, completion: nil)
    }
    
    @IBAction func selectPlaceBtnPressed(_ sender: Any) {
        let selectPlaceVC = SelectPlaceVC()
        selectPlaceVC.modalPresentationStyle = .custom
        selectPlaceVC.delegate = self
        presentDetail(selectPlaceVC)
    }
    
    func setYesterday(){
        yesterdayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
    }
    
    func setToday() {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        otherDateBtn.setImage(nil, for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        otherDateBtn.setTitle("Other", for: .normal)
    }
    
    func setOtherDay() {
        yesterdayBtn.setImage(nil, for: .normal)
        todayBtn.setImage(nil, for: .normal)
        otherDateBtn.setImage(UIImage(named:  "checkmark-round_yellow16_16"), for: .normal)
        yesterdayBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        todayBtn.setTitleColor(#colorLiteral(red: 0.662745098, green: 0.662745098, blue: 0.662745098, alpha: 1), for: .normal)
        otherDateBtn.setTitleColor(#colorLiteral(red: 1, green: 0.831372549, blue: 0.02352941176, alpha: 1), for: .normal)
    }
}

extension AddTransactionAdditionalVC: CalendarProtocol, UITextViewDelegate, UITextFieldDelegate{
    func handleDate(_ date: Date, start: Bool) {
        self.date = date
        otherDateBtn.setTitle(date.formatDateToStr(), for: .normal)
        setOtherDay()
    }

    func textViewDidChange(_ textView: UITextView) {
        if let text = descriptionTV.text {
            placeholderLabel?.isHidden = !text.isEmpty
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tagTxt {
            tagTxt.leftView = tagImageView
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tagTxt {
            tagTxt.leftView = nil
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !text.isEmpty {
                tags.append((text, false))
                rebuildTagsUIElements()
                tagTxt.text = ""
            } else {
                self.view.endEditing(true)
            }
        }
        return true
    }
}

extension AddTransactionAdditionalVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        image = ImageHelper.instance.imageOrientation(image)
        self.photos.append(["":image])
        self.photosCollectionView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddTransactionAdditionalVC: PhotoProtocol, PlaceProtocol {
    func handlePhotos(photos: [[String : UIImage]]) {
        self.photos = photos
        photosCollectionView.reloadData()
    }
    func handlePlace(_ place: Place) {
        self.place = place
        self.selectPlaceBtn.setTitle(place.name, for: .normal)
    }
}

extension AddTransactionAdditionalVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photosCollectionView {
            
        } else {
            scrollView.contentSize.height = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == photosCollectionView {
            return photos.count
        } else {
            return tags.count
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photosCollectionView {
            if let cell = photosCollectionView?.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell {
                cell.configureCell(image: ImageHelper.instance.getPhotoImagebyIndex(index: indexPath.row, photos: self.photos))
                return cell
            }
        } else {
            if let cell = tagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell {
                cell.configureCell(title: tags[indexPath.row].name, selected: tags[indexPath.row].selected)
                cell.closeBtn.tag = indexPath.row
                cell.closeBtn.addTarget(self, action: #selector(AddTransactionAdditionalVC.handleCellCloseBtnPressed), for: UIControlEvents.touchUpInside)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    @objc func handleCellCloseBtnPressed(sender : UIButton!){
        guard let transaction = self.transaction else {
            tags.remove(at: sender.tag)
            rebuildTagsUIElements()
            tagsCollectionView?.reloadData()
            return
        }
        CoreDataService.instance.fetchTag(name: tags[sender.tag].name, transaction: transaction) { (tag) in
            if tag.count > 0 {
                CoreDataService.instance.removeTag(tag: tag[0])
            }
            tags.remove(at: sender.tag)
            rebuildTagsUIElements()
            tagsCollectionView?.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 100
        var height: CGFloat = 100
        if collectionView == self.tagsCollectionView {
            let size = tags[indexPath.row].name.estimatedFrameForText(maxFrameWidth: scrollView.frame.width)
            width = size.width + 24
            height = 24
        } else if collectionView == self.photosCollectionView{
            width = self.photosCollectionView.frame.width / 2
            height = width
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.tagsCollectionView {
            if let cell = tagsCollectionView?.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as? TagCell {
                deselectAllcell()
                tags[indexPath.row].selected = true
                collectionView.reloadData()
            }
        } else if collectionView == self.photosCollectionView {
            let photoVC = PhotoVC()
            photoVC.modalPresentationStyle = .custom
            photoVC.photos = self.photos
            photoVC.openedImage = indexPath.row
            photoVC.delegate = self
            present(photoVC, animated: true, completion: nil)
        }
    }
    
    func deselectAllcell(){
        for (index, value) in self.tags.enumerated() {
            let item = (value.name, false)
            tags.remove(at: index)
            tags.insert(item, at: index)
        }
    }
}
