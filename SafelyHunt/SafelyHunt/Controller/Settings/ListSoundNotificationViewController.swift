//
//  ListSoundNotificationViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 22/10/2022.
//

import UIKit

class ListSoundNotificationViewController: UIViewController {
// MARK: - Properties
    let sounds: [String] = [
        "Orchestral-emergency",
        "Scanning-alarm",
        "melodical-flute-music-notification",
        "morning-clock-alarm",
        "musical-alert-notification",
        "retro-game-emergency-alarm",
        "security-facility-breach-alarm",
        "space-shooter-alarm",
        "street-public-alarm",
        "uplifting-flute-notification",
        "warning-alarm-buzzer"
    ]
    let notification = LocalNotification()

// MARK: - IBOutlet
    @IBOutlet weak var soundsTableView: UITableView!

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableView DataSource
extension ListSoundNotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "soundsCell", for: indexPath)
        let nameSound = sounds[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = nameSound
            content.textProperties.color = .black
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = nameSound
        }

        if nameSound == UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.notificationSoundName) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.tintColor = #colorLiteral(red: 0.2238582075, green: 0.3176955879, blue: 0.2683802545, alpha: 1)
        return cell
    }
}

// MARK: - UITableView Delegate
extension ListSoundNotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UserDefaults.standard.set(sounds[indexPath.row], forKey: UserDefaultKeys.Keys.notificationSoundName)
        tableView.reloadData()
       notification.playAlert()
    }
}
