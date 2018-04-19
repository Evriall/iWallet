//
//  UIViewExt.swift
//  goalpost-app
//
//  Created by Sergey Guznin on 3/23/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

extension UIView {
    func bindToKeyBoard(){
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyBoardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    func removeObserverToKeyBoard(){
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyBoardWillChange(_ notification: Notification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let startingFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endingFrame.origin.y - startingFrame.origin.y
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve) , animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
    func animateToggleAlpha() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = self.alpha == 1 ? 0 : 1
        }
    }
}
