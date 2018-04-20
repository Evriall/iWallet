//
//  DateExt.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/3/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import Foundation

extension Date {
//    func startOfMonth() -> Date {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
//    }
//
//    func startOfDay() -> Date {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.date(from: calendar.dateComponents([.day,.year, .month], from: calendar.startOfDay(for: self)))!
//    }
//
//    func isToday() -> Bool {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.isDateInToday(self)
//    }
//
//
//    func endOfMonth() -> Date {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
//    }
//    func previousMonth() -> Date {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.date(byAdding: DateComponents(month: -1, day: 0), to: self)!
//    }
//    func nextMonth() -> Date {
//        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//        return calendar.date(byAdding: DateComponents(month: 1, day: 0), to: self)!
//    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func startOfDay() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.day,.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func isToday() -> Bool {

        return Calendar.current.isDateInToday(self)
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
    
    func fixerStr() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func fourSquareStr() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
}
