//
//  LocalNotification.swift
//  SafelyHunt
//
//  Created by Yoan on 11/08/2022.
//

import Foundation
import UIKit

class LocalNotification {
    let notificationCenter = UNUserNotificationCenter.current()
    let notification = UNMutableNotificationContent()

    func notificationInitialize() {
        prepareMyAlert()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
            }
        }
    }

    func sendNotification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier:
                                                            UUID().uuidString, content: notification, trigger: trigger)
        notificationCenter.add(notificationRequest)
        UIApplication.shared.applicationIconBadgeNumber += 1
    }

    private func prepareMyAlert() {
        let notificationSound = UNNotificationSoundName.init(rawValue: "orchestralEmergency.caf")
        notification.title = "Attention !!!"
        notification.body = "Required your attention"
        notification.categoryIdentifier = "StopMonitoring.category"
        notification.sound = UNNotificationSound(named: notificationSound)
    }
}
