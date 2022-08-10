//
//  DateExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 06/08/2022.
//

import Foundation

extension Date {
    func relativeDate(dateInt: Int) -> String {
        let myDate = Date(timeIntervalSince1970: TimeInterval(dateInt))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
//       return formatter.localizedString(for: myDate, relativeTo: Date())
       return DateFormatter.localizedString(from: myDate, dateStyle: .short, timeStyle: .medium)
    }
    
    func dateToTimeStamp()-> Int {
        Int(self.timeIntervalSince1970)
    }
}
