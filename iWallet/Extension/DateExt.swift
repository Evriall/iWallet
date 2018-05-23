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
    
    func startOfYear() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func startOfWeek() -> Date {
        var dayOffset = 0
        let dayNumberOfWeek = self.dayNumberOfWeek() ?? 2
        if dayNumberOfWeek < 2 {
            dayOffset = -6
        } else {
            dayOffset = -(dayNumberOfWeek - 2)
        }
        
        return Calendar.current.date(byAdding: DateComponents(day: dayOffset), to: self.startOfDay())!
    }
    
    func startOfDay() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.day,.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func isToday() -> Bool {

        return Calendar.current.isDateInToday(self)
    }
    func endOfDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1, second: -1), to: self.startOfDay())!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, second: -1), to: self.startOfMonth())!
    }
    
    func endOfWeek() -> Date {
        return Calendar.current.date(byAdding: DateComponents(second: -1, weekOfYear: 1), to: self.startOfWeek())!
    }
    
    func endOfYear() -> Date {
        return Calendar.current.date(byAdding: DateComponents(year: 1, second: -1), to: self.startOfYear())!
    }
    
    func previousMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: -1), to: self)!
    }
    func nextMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self)!
    }
    
//    func endOfMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
//    }
//
//    func endOfWeek() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(day: -1, weekOfYear: 1), to: self.startOfWeek())!
//    }
//
//    func endOfYear() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(year: 1, day: -1), to: self.startOfYear())!
//    }
//
//    func previousMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: -1, day: 0), to: self)!
//    }
//    func nextMonth() -> Date {
//        return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: self)!
//    }
    
    func formatDateToStr() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: self)
    }
    
    func ChartStr() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
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
