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
        playAlert()
    }

    private func prepareMyAlert() {
        let notificationSound = UNNotificationSoundName.init(rawValue: "scanning-alarm.mp3")
        notification.title = "Attention !!!"
        notification.body = "Required your attention"
        notification.categoryIdentifier = "StopMonitoring.category"
        notification.sound = UNNotificationSound(named: notificationSound)
    }

    private func playAlert() {
        let path = Bundle.main.path(forResource: "scanning-alarm.mp3", ofType: nil)!
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
