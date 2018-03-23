//
//  UIViewControllerExt.swift
//  goalpost-app
//
//  Created by Sergey Guznin on 3/23/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentDetail( _ viewControllerToPresent: UIViewController){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent , animated: false, completion: nil)
    }
    
    func dismissDetail(){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
    
    func presentSecondaryDetail( _ viewControllerToPresent: UIViewController){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        guard let presenstedViewController = presentedViewController else {return}
        presentedViewController?.dismiss(animated: false, completion: {
            self.view.window?.layer.add(transition, forKey: kCATransition)
            self.present(viewControllerToPresent, animated: false, completion: nil)
        })
    }
}
