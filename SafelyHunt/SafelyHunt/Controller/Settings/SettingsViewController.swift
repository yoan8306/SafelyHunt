//
//  SettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SettingsViewController: UIViewController {
// MARK: - IBOutlet
    @IBOutlet weak var settingTableView: UITableView!

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
    }
}

// MARK: - TableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainData.mainSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = MainData.mainSettings[indexPath.row]

        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
        }

        return cell
    }

}

// MARK: - TableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            transferToProfile()
        case 1:
            presentRanking()
        case 2:
            openSettingApp()
        case 3:
            presentTutorial()
        case 4:
            presentListSoundNotification()
        case 5:
            transferToAccountSetting()
        default:
            break
        }
    }

    /// Open ProfileController
    private func transferToProfile() {
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController else {return}
        profileViewController.navigationItem.title = "Profile"
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    /// Open AccountSettingController
    private func transferToAccountSetting() {
        let accountSettingStoryboard = UIStoryboard(name: "AccountSettings", bundle: nil)
        guard let accountSettingViewController = accountSettingStoryboard.instantiateViewController(withIdentifier: "AccountSettings") as? AccountSettingsViewController else {return}

        accountSettingViewController.navigationItem.title = "Account".localized(tableName: "LocalizableMainData")
        navigationController?.pushViewController(accountSettingViewController, animated: true)
    }

    private func presentTutorial() {
        let carouselStoryboard = UIStoryboard(name: "Carousel", bundle: nil)

        guard let carouselVC = carouselStoryboard.instantiateViewController(withIdentifier: "CarouselStoryboard") as? CarouselViewController else {
            return
        }
        present(carouselVC, animated: true)
    }

    private func presentRanking() {
        let rankingStoryboard = UIStoryboard(name: "Ranking", bundle: nil)

        guard let rankingViewController = rankingStoryboard.instantiateViewController(withIdentifier: "Ranking") as? RankingViewController else {return}

        rankingViewController.navigationItem.title = "Ranking".localized(tableName: "LocalizableMainData")
        navigationController?.pushViewController(rankingViewController, animated: true)

    }

    /// Open setting application
    private func openSettingApp() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {return}

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }

    private func presentListSoundNotification() {
        let soundsNotificationStoryboard = UIStoryboard(name: "SoundNotification", bundle: nil)
        guard let soundsNotificationViewController = soundsNotificationStoryboard.instantiateViewController(withIdentifier: "SoundNotification") as? ListSoundNotificationViewController else {return}

        present(soundsNotificationViewController, animated: true)
    }
}
