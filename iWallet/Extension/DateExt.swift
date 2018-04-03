//
//  DateExt.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/3/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    func previousMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: -1, day: 0), to: self)!
    }
    func nextMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: self)!
    }
    
    func formatDateToStr() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: self)
    }
}
