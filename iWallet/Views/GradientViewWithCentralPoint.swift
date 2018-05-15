//
//  GradientViewWithCentralPoint.swift
//  iWallet
//
//  Created by Sergey Guznin on 5/14/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit

 @IBDesignable

class GradientViewWithCentralPoint: UIImageView {
        @IBInspectable var centralColor: UIColor = #colorLiteral(red: 0.2901960784, green: 0.3019607843, blue: 0.8470588235, alpha: 1) {
            didSet {
                self.setNeedsLayout()
            }
        }
        
        @IBInspectable var sideColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1){
            didSet {
                self.setNeedsLayout()
            }
        }
        
        override func layoutSubviews() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [centralColor.cgColor, sideColor.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            gradientLayer.frame = self.bounds
            
//            let gradientLayer2 = CAGradientLayer()
//            gradientLayer2.colors = [centralColor.cgColor, sideColor.cgColor]
//            gradientLayer2.startPoint = CGPoint(x: 0.5, y: 0.5)
//            gradientLayer2.endPoint = CGPoint(x: 0, y: 0)
//            gradientLayer2.frame = self.bounds
            
            self.layer.insertSublayer(gradientLayer, at: 0)
//            self.layer.insertSublayer(gradientLayer2, at: 1)
        }
}

