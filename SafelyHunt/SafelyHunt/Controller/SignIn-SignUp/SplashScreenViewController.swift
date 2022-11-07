//
//  SplashScreenViewController.swift
//  SafelyHunt
//
//  Created by Yoan on 07/07/2022.
//

import UIKit

class SplashScreenViewController: UIViewController {

// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// check if user is sign in or not If user is sign in go to main, if not go to login page
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        UserServices.shared.checkUserLogged { [weak self] person in
            switch person {
            case .success(let person):
                guard let self = self else {
                    self?.transferToLogin()
                    return
                }
                if self.dayAreSaved() {
                    UserDefaults.standard.setValue(Date().dateToTimeStamp(), forKey: UserDefaultKeys.Keys.savedDate)
                    UserDefaults.standard.setValue("unknown", forKey: UserDefaultKeys.Keys.personMode)
                    self.presentPersonMode()
                } else {
                    self.transferToMainStarter(person: person)
                }

            case .failure(_):
                self?.transferToLogin()
            }
        }
    }

    /// remove observer logged user
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        UserServices.shared.removeStateChangeLoggedListen()
    }

    // MARK: - private functions
    /// transfer to main starter controller
    /// - Parameter hunter: hunter logged
    private func transferToMainStarter(person: Person) {
        let mainStarterStoryboard = UIStoryboard(name: "TabbarMain", bundle: nil)

        guard let mainStarterViewController = mainStarterStoryboard.instantiateViewController(withIdentifier: "TabbarMain") as? UITabBarController else {return}

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainStarterViewController, animationOption: .transitionCrossDissolve)
    }

    private func presentPersonMode() {
        let personModeStoryboard = UIStoryboard(name: "PersonMode", bundle: nil)
        guard let personModeViewController = personModeStoryboard.instantiateViewController(withIdentifier: "PersonMode") as? PersonModeViewController else {return}
        present(personModeViewController, animated: true)
    }

    /// transfert to LoginView controller
    private func transferToLogin() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)

        guard let loginViewController = loginStoryboard.instantiateViewController(withIdentifier: "LoginNavigation") as? UINavigationController else {return}

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController, animationOption: .transitionCrossDissolve)
    }

    private func dayAreSaved() -> Bool {
        let date = Date()
        let timeStampeSaved = UserDefaults.standard.integer(forKey: UserDefaultKeys.Keys.savedDate)
        let savedDate = Date(timeIntervalSince1970: TimeInterval(timeStampeSaved))
        return  Calendar.current.compare(date, to: savedDate, toGranularity: .day)  == .orderedDescending
    }
}
