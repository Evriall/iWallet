//
//  PhotoVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/18/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class PhotoVC: UIViewController {
    
    @IBOutlet weak var scrollView: ScrollViewWithTopAndBottomFixedViews!
    var photos = [[String: UIImage]]()
    var openedImage: Int  = 0{
        didSet{
            self.prepareUIElementsToShowParticularPhoto()
        }
    }
    var delegate: PhotoProtocol?
    var imageView : UIImageView?
    var positionLbl = UILabel()

    func prepareUIElementsToShowParticularPhoto(){
        guard let scrollView = self.scrollView else {return}
        positionLbl.text = positionDescription()
        if openedImage == 0 {
            scrollView.backButton.isEnabled = false
        } else {
            scrollView.backButton.isEnabled = true
        }
        if openedImage == photos.count - 1 {
            scrollView.forwardButton.isEnabled = false
        } else {
            scrollView.forwardButton.isEnabled = true
        }
        imageView?.image = ImageHelper.instance.getPhotoImagebyIndex(index: openedImage, photos: photos)
        scrollView.zoomScale = 1.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.zoomScale = 1
        self.prepareUIElementsToShowParticularPhoto()
        scrollView.closeButton.addTarget(self, action: #selector(PhotoVC.closeBtnPressed), for: .touchUpInside)
        scrollView.deleteButton.addTarget(self, action: #selector(PhotoVC.deleteBtnPressed), for: .touchUpInside)
        scrollView.backButton.addTarget(self, action: #selector(PhotoVC.backBtnPressed), for: .touchUpInside)
        scrollView.forwardButton.addTarget(self, action: #selector(PhotoVC.forwardBtnPressed), for: .touchUpInside)
        positionLbl.font = UIFont(name: "Avenir-Book", size: 24)
        positionLbl.text = positionDescription()
        positionLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        positionLbl.frame = CGRect(x: (scrollView.frame.width/2) - ((positionLbl.text?.estimatedFrameForText(fontSize: 24, height: 24, maxFrameWidth: scrollView.frame.width).width)!/2), y: CGFloat(18.0), width: (positionLbl.text?.estimatedFrameForText(fontSize: 24, height: 24, maxFrameWidth: scrollView.frame.width).width)!, height: CGFloat(24.0))
        
        scrollView.bottomView.addSubview(positionLbl)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
        imageView?.contentMode = .scaleAspectFit
        imageView?.image = ImageHelper.instance.getPhotoImagebyIndex(index: openedImage, photos: photos)
        scrollView.addSubview(imageView!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PhotoVC.handleTap))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(){
        self.scrollView.toggleHiddenViews()
    }
    
    @objc func closeBtnPressed(){
        delegate?.handlePhotos(photos: self.photos)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func backBtnPressed(){
        openedImage -= 1
        self.prepareUIElementsToShowParticularPhoto()
    }
    
    @objc func forwardBtnPressed(){
        openedImage += 1
        self.prepareUIElementsToShowParticularPhoto()
    }
    
    @objc func deleteBtnPressed(){
        if photos.count == 0 {
            delegate?.handlePhotos(photos: photos)
            dismiss(animated: true, completion: nil)
        } else {
            let photoName = ImageHelper.instance.getPhotoNamebyIndex(index: openedImage, photos: photos)
            if !photoName.isEmpty {
                CoreDataService.instance.fetchPhoto(name: photoName) { (photos) in
                    for item in photos {
                        CoreDataService.instance.removePhoto(item)
                    }
                }
            }
            photos.remove(at: openedImage)
            if self.photos.count == 0 {
                delegate?.handlePhotos(photos: self.photos)
                dismiss(animated: true, completion: nil)
            } else {
                openedImage -= (openedImage == 0) ? 0 : 1
                self.prepareUIElementsToShowParticularPhoto()
                imageView?.image = ImageHelper.instance.getPhotoImagebyIndex(index: openedImage, photos: photos)
            }
        }
    }
    
    func positionDescription()-> String{
        return "\(openedImage+1)/\(photos.count)"
    }
    
    
    @IBAction func handlePanGesture(_ sender: DirectedPanGestureRecognizer) {
        let percentX = max(sender.translation(in: view).x, 0) / self.view.frame.width
        let percentY = max(sender.translation(in: view).y, 0) / self.view.frame.height
        let percent = percentX > percentY ? percentX : percentY
        switch sender.state {
            
//        case .began:
            
        case .changed:
            if sender.direction == .down || sender.direction == .up{
                self.view.alpha = 1 - percent*2
//                self.scrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1 - percent*2)
//                self.imageView?.alpha = 1 - percent*2
                if sender.direction == .down {
                    self.view.frame.origin.y = percent * self.view.frame.height
                } else if sender.direction == .up {
                    self.view.frame.origin.y = -percent * self.view.frame.height
                }
            }
        case .ended:
//            let velocity = sender.velocity(in: view).x
           
            if percent > 0.25{
                if sender.direction == .down {
                    delegate?.handlePhotos(photos: self.photos)
                    dismiss(animated: true, completion: nil)
                }
                else if sender.direction == .up{
                    delegate?.handlePhotos(photos: self.photos)
                    dismissDetailUp()
                } else if sender.direction == .right{
                    openedImage -= openedImage == 0 ? -(photos.count - 1) : 1
                }
            } else if sender.direction == .left{
                    openedImage += openedImage == (photos.count - 1) ? -(photos.count - 1) : 1
            }else {
//                self.scrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//                self.imageView?.alpha =  1
                self.view.alpha = 1
                self.view.frame.origin.y = 0
            }
            
        case .cancelled, .failed:
            self.scrollView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            self.imageView?.alpha =  1
            self.view.frame.origin.y = 0
        default:
            break
        }
    }

}



extension PhotoVC: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        } else {
            return true
        }
    }
   
}
