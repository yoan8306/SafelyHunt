//
//  LocalNotification.swift
//  SafelyHunt
//
//  Created by Yoan on 11/08/2022.
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

class LocalNotification {
    let notificationCenter = UNUserNotificationCenter.current()
    let notification = UNMutableNotificationContent()
    var alertSong: AVAudioPlayer?

    /// Initialize notification
    func notificationInitialize() {
        prepareAlert()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {(_, _) in
        }
    }

    /// send notification
    func sendNotification() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let notificationRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notification,
            trigger: trigger
        )

        notificationCenter.add(notificationRequest)
        UIApplication.shared.applicationIconBadgeNumber += 1
        playAlert()
    }

    /// initiatilaze info into notification
    private func prepareAlert() {
        let notificationSound = UNNotificationSoundName.init(rawValue: "orchestralEmergency.caf")
        notification.title = "Attention !!!"
        notification.body = "Required your attention"
        notification.categoryIdentifier = "StopMonitoring.category"
        notification.sound = UNNotificationSound(named: notificationSound)
    }

    /// play custom song notification
    private func playAlert() {
        let path = Bundle.main.path(forResource: "orchestralEmergency.caf", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            alertSong = try AVAudioPlayer(contentsOf: url)
            alertSong?.play()
        } catch {
            print("file isn't  food!")
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
