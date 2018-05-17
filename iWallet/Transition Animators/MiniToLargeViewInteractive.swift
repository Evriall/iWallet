//
//  MiniToLargeViewInteractive.swift
//  DraggableViewController
//
//  Created by Jiri Ostatnicky on 18/05/16.
//  Copyright © 2016 Jiri Ostatnicky. All rights reserved.
//

import UIKit

class MiniToLargeViewInteractive: UIPercentDrivenInteractiveTransition {
    
    var viewController: UIViewController?
    var presentViewController: UIViewController?
    var pan: UIPanGestureRecognizer!
    var viewWidth : CGFloat = 0.0
    var shouldComplete = false
    var lastProgress: CGFloat?
    
    func attachToViewController(viewController: UIViewController, withView view: UIView, presentViewController: UIViewController?) {
        self.viewController = viewController
        self.presentViewController = presentViewController
        self.viewWidth = view.frame.width
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.onPan(pan:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view?.superview)
        
        //Represents the percentage of the transition that must be completed before allowing to complete.
        let percentThreshold: CGFloat = 0.2
        //Represents the difference between progress that is required to trigger the completion of the transition.
        let automaticOverrideThreshold: CGFloat = 0.03
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width - self.viewWidth
        let dragAmount: CGFloat = (presentViewController == nil) ? screenWidth : -screenWidth
        var progress: CGFloat = translation.x / dragAmount
        
        progress = fmax(progress, 0)
        progress = fmin(progress, 1)
        switch pan.state {
        case .began:
            if let presentViewController = presentViewController {
                let transition = CATransition()
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                viewController?.view.window?.layer.add(transition, forKey: kCATransition)
                viewController?.present(presentViewController, animated: true, completion: nil)
            } else {
                let transition = CATransition()
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromLeft
                viewController?.view.window?.layer.add(transition, forKey: kCATransition)
                viewController?.dismiss(animated: true)
            }
            
        case .changed:
            guard let lastProgress = lastProgress else {return}
            
            // When swiping back
            if lastProgress > progress {
                shouldComplete = false
                // When swiping quick to the right
            } else if progress > lastProgress + automaticOverrideThreshold {
                shouldComplete = true
            } else {
                // Normal behavior
                shouldComplete = progress > percentThreshold
            }
            update(progress)
            
        case .ended, .cancelled:
            if pan.state == .cancelled || shouldComplete == false {
                cancel()
            } else {
                finish()
            }
            
        default:
            break
        }
        
        lastProgress = progress
    }
}
