//
//  SettingsViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainStarterData().mainSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = MainStarterData().mainSettings[indexPath.row]

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

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            transferToProfile()
        case 1:
            transferToAccountSetting()
        default:
            break
        }
    }

    private func transferToProfile() {
        let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)

        guard let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController else {
            return
        }

        navigationController?.pushViewController(profileViewController, animated: true)
    }

    private func transferToAccountSetting() {
        let accountSettingStoryboard = UIStoryboard(name: "AccountSettings", bundle: nil)

        guard let accountSettingViewController = accountSettingStoryboard.instantiateViewController(withIdentifier: "AccountSettings") as? AccountSettingsViewController else {
            return
        }
        accountSettingViewController.navigationItem.title = "Account"
        navigationController?.pushViewController(accountSettingViewController, animated: true)
    }
}
