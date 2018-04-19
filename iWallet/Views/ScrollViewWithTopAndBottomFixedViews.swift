//
//  ScrollViewWithTopAndBottomFixedViews.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/19/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

class ScrollViewWithTopAndBottomFixedViews: UIScrollView {

    let topView =  UIView()
    let bottomView =  UIView()
    let closeButton = UIButton()
    let deleteButton = UIButton()
    let backButton = UIButton()
    let forwardButton = UIButton()
    let positionLbl = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let locationTop = CGPoint(x: contentOffset.x, y: contentOffset.y)
        let sizeTop = CGSize(width: self.frame.width, height: 77)
        topView.frame = CGRect(origin: locationTop, size: sizeTop)
        topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
//        topView.isHidden = true
        let locationBottom = CGPoint(x: contentOffset.x, y: contentOffset.y + self.frame.height - 50)
        let sizeBottom = CGSize(width: self.frame.width, height: 50)
        bottomView.frame = CGRect(origin: locationBottom, size: sizeBottom)
        bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
//        bottomView.isHidden = true
        closeButton.frame = CGRect(x: 20, y: 46, width: 18, height: 18)
        closeButton.setImage(UIImage(named: "close") , for: .normal)
        deleteButton.frame = CGRect(x: self.frame.width - 52, y: 40, width: 32, height: 32)
        deleteButton.setImage(UIImage(named: "TrashIcon") , for: .normal)
        topView.addSubview(deleteButton)
        topView.addSubview(closeButton)
        backButton.frame = CGRect(x: 50, y: 16, width: 32, height: 24)
        backButton.setImage(UIImage(named: "back") , for: .normal)
        forwardButton.frame = CGRect(x: self.frame.width - 82, y: 16, width: 32, height: 24)
        forwardButton.setImage(UIImage(named: "forward") , for: .normal)
        bottomView.addSubview(backButton)
        bottomView.addSubview(forwardButton)
        
        self.addSubview(bottomView)
        self.addSubview(topView)
    }

    func toggleHiddenViews(){
        let duration = 0.5
        let delay = 0.0 // delay will be 0.0 seconds (e.g. nothing)
        let options = UIViewAnimationOptions.curveEaseIn // change the timing curve to `ease-in ease-out`
        let bottomViewHeight = self.bottomView.frame.height > 0 ? 0 : 50
        let topViewHeight = self.topView.frame.height > 0 ? 0: 77
        UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 7), animations: {
            self.bottomView.frame.origin.y = self.bottomView.frame.origin.y == (self.contentOffset.y + self.frame.height - CGFloat(50)) ? self.bottomView.frame.origin.y + 50 : (self.contentOffset.y + self.frame.height - CGFloat(50))
            self.topView.frame.origin.y = self.topView.frame.origin.y == 0 ? -77 : 0
        },completion: nil)
    }
}
