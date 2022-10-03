//
//  DateExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 06/08/2022.
//

import Foundation

extension Date {
    func relativeDate(relativeTo: Date, locale: Locale = .current) -> String {
        let myDate = self
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = locale
       return formatter.localizedString(for: myDate, relativeTo: relativeTo)
    }

    func dateToTimeStamp() -> Int {
        Int(self.timeIntervalSince1970)
    }

    func getTime(locale: Locale = .current) -> String {
        let myHour = self
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        formatter.locale = locale
        return formatter.string(from: myHour)
    }
}
