//
//  DateExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 06/08/2022.
//

import Foundation

extension Date {
    func relativeDate(relativeTo: Date) -> String {
        let myDate = self
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
       return formatter.localizedString(for: myDate, relativeTo: relativeTo)
    }

    func dateToTimeStamp() -> Int {
        Int(self.timeIntervalSince1970)
    }

    func getTime() -> String {
        let myHour = self
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: myHour)
    }
}
