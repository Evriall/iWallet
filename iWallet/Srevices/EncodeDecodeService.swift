//
//  EncodeDecodeService.swift
//  iWallet
//
//  Created by Sergey Guznin on 3/24/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

class EncodeDecodeService{
    static let instance = EncodeDecodeService()
    func returnUIColor(components: String?) -> UIColor{
        let defaultColor = UIColor.lightGray
        guard let unwrappedComponents = components else {return defaultColor}
        let scanner = Scanner(string: unwrappedComponents)
        let skipped = CharacterSet(charactersIn: "[], ")
        let comma = CharacterSet(charactersIn: ",")
        scanner.charactersToBeSkipped = skipped
        
        var r,g,b,a : NSString?
        
        scanner.scanUpToCharacters(from: comma, into: &r)
        scanner.scanUpToCharacters(from: comma, into: &g)
        scanner.scanUpToCharacters(from: comma, into: &b)
        scanner.scanUpToCharacters(from: comma, into: &a)
     
        
        guard let rUnwrapped = r, let gUnwrapped = g, let bUnwrapped = b, let aUnwrapped = a else { return defaultColor}
        let rfloat = CGFloat(rUnwrapped.doubleValue)
        let gfloat = CGFloat(gUnwrapped.doubleValue)
        let bfloat = CGFloat(bUnwrapped.doubleValue)
        let afloat = CGFloat(aUnwrapped.doubleValue)
        
        let newUIColor = UIColor(red: rfloat, green: gfloat, blue: bfloat, alpha: afloat)
        return newUIColor
    }
    
    func fromUIColorToStr(color: UIColor?) -> String {
        guard let colorToDecode = color, let component = colorToDecode.cgColor.components else {return "[0.5, 0.5, 0.5, 1]"}
        let r = component[0]
        let g = component[1]
        let b = component[2]
        let a = component[3]
        let color = "[\(r), \(g), \(b), \(a)]"
        return color
    }
    
    func transformCurrencyRate(value: Double) -> (multiplier: Int, newValue: Double) {
        var multiplier  = 1
        var value = value
        while value < 1 {
            value *= 10
            multiplier *= 10
        }
        return (multiplier, value)
    }
}
