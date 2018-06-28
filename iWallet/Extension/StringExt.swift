//
//  StringExt.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/10/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    
    func estimatedFrameForText(fontSize: CGFloat = 17.0, height: CGFloat = 24.0, maxFrameWidth: CGFloat) -> CGRect {
        let size = CGSize(width: maxFrameWidth, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        guard let attributes = [NSAttributedStringKey.font:  UIFont(name: "Avenir-Book", size: fontSize)] as? [NSAttributedStringKey: Any] else {return CGRect(x: 0, y: 0, width: 70, height: 24)}
        return NSString(string: self).boundingRect(with: size, options: options, attributes: attributes, context: nil)
    }
    
    func updateServerDate() -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.date(from: self)
    }
}
