//
//  PersonModeViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 25/10/2022.
//

import UIKit

class PersonModeViewController: UIViewController {

    @IBOutlet weak var huntBoutton: UIButton!
    @IBOutlet weak var walkerBoutton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }

    @IBAction func closeButtonAction() {
        let personModeChoose = UserDefaults.standard.string(forKey: UserDefaultKeys.Keys.personMode)
        let personModeEnum = PersonMode(rawValue: personModeChoose ?? "unknown")
        switch personModeEnum {
        case .hunter, .walker:
        transferToMainStarter()
        default:
            presentAlertError(alertMessage: "Select a choice".localized(tableName: "Localizable"))
        }
    }

    @IBAction func walkerButtonAction() {
        setView()
        UserDefaults.standard.set("walker", forKey: UserDefaultKeys.Keys.personMode)
        transferToMainStarter()
    }

    @IBAction func huntButtonAction() {
        setView()
        UserDefaults.standard.set("hunter", forKey: UserDefaultKeys.Keys.personMode)
        transferToMainStarter()
    }

    private func setView() {
        huntBoutton.layer.cornerRadius = huntBoutton.frame.height/2
        walkerBoutton.layer.cornerRadius = walkerBoutton.frame.height/2

        switch Person().personMode {
        case .unknown:
            huntBoutton.alpha = 1
            walkerBoutton.alpha = 1
            self.isModalInPresentation = true
        case .hunter:
            huntBoutton.alpha = 1
            walkerBoutton.alpha = 0.5
            self.isModalInPresentation = false
        case .walker:
            walkerBoutton.alpha = 1
            huntBoutton.alpha = 0.5
            self.isModalInPresentation = false
        case .none:
            huntBoutton.alpha = 1
            walkerBoutton.alpha = 1
            self.isModalInPresentation = true
        }
    }

    private func transferToMainStarter() {
        let mainStarterStoryboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {return}

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarterViewController, animationOption: .curveLinear)
    }
}
