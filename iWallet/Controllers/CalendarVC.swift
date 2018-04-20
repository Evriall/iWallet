//
//  CalendarVC.swift
//  iWallet
//
//  Created by Sergey Guznin on 4/1/18.
//  Copyright © 2018 Sergey Guznin. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarVC: UIViewController {

    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    
    private var selectedDay: DayView!
    private var currentCalendar: Calendar?
    var delegate: CalendarProtocol?
    var currentDate = Date()
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismissDetail()
    }
    override func awakeFromNib() {
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "eng_ENG")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuView.menuViewDelegate = self
        calendarView.calendarDelegate = self
        calendarView.calendarAppearanceDelegate = self
        if let currentCalendar = currentCalendar {
            monthLbl.text = CVDate(date: Date(), calendar: currentCalendar).globalDescription
        }
        calendarView.contentController.refreshPresentedMonth()
//        calendarView.toggleViewWithDate(currentDate)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }

}

extension CalendarVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate{
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        guard let selectedDate = dayView.date.convertedDate() else {
            return
        }
        delegate?.handleDate(selectedDate)
        dismissDetail()
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.frame, shape: CVShape.circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        guard let date = dayView.date.convertedDate()?.startOfDay() else {return circleView}
        if date == currentDate.startOfDay() {
          circleView.fillColor = .colorFromCode(0x00DADF)
        }
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        guard let date = dayView.date.convertedDate()?.startOfDay() else {return false}
        if (dayView.isCurrentDay || date == currentDate.startOfDay()) {
            return true
        }
        return false
    }
    
    
    func presentedDateUpdated(_ date: CVDate) {
        monthLbl.text = date.globalDescription
    }
    func shouldAutoSelectDayOnMonthChange() -> Bool { return false }
    
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return weekday == .sunday ? UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0) : #colorLiteral(red: 0, green: 0.568627451, blue: 0.5764705882, alpha: 1)
        
    }
    
    func dayLabelWeekdayDisabledColor() -> UIColor { return .lightGray }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool { return false }
    
    func spaceBetweenDayViews() -> CGFloat { return 0 }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont { return UIFont.systemFont(ofSize: 14) }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (_, .selected, _), (_, .highlighted, _): return ColorsConfig.selectedText
        case (.sunday, .in, _): return ColorsConfig.sundayText
        case (.sunday, _, _): return ColorsConfig.sundayTextDisabled
        case (_, .in, _): return ColorsConfig.text
        default: return ColorsConfig.textDisabled
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status, present) {
        case (.sunday, .selected, _), (.sunday, .highlighted, _): return ColorsConfig.sundaySelectionBackground
        case (_, .selected, _), (_, .highlighted, _): return ColorsConfig.selectionBackground
        default: return nil
        }
    }
    
//    func didShowNextMonthView(_ date: Date) {
////        calendarView.contentController.refreshPresentedMonth()
//    }
}
