//
//  UIViewController_Alert.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation
import UIKit
import SPAlert

extension UIViewController {

    func presentAlertError (alertTitle title: String = "Error".localized(tableName: "Localizable"),
                            alertMessage message: String,
                            buttonTitle titleButton: String = "Dismiss".localized(tableName: "Localizable"),
                            alertStyle style: UIAlertAction.Style = .cancel ) {
        let colorTintButton = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        action.setValue(colorTintButton, forKey: "titleTextColor")
        present(alertVC, animated: true, completion: nil)
    }
    func presentAlertSuccess (alertTitle title: String = "Success", alertMessage message: String,
                              buttonTitle titleButton: String = "Ok",
                              alertStyle style: UIAlertAction.Style = .cancel ) {
        let colorTintButton = #colorLiteral(red: 0.6659289002, green: 0.5453534722, blue: 0.3376245499, alpha: 1)
               let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
               let action = UIAlertAction(title: titleButton, style: style, handler: nil)
               alertVC.addAction(action)
        action.setValue(colorTintButton, forKey: "titleTextColor")
               present(alertVC, animated: true, completion: nil)
           }

    func presentNativeAlertSuccess(alertTitle title: String = "Success".localized(tableName: "Localizable"), alertMessage message: String) {
        let alertView = SPAlertView(title: title, message: message, preset: .done)
        alertView.duration = 3
        alertView.present()
    }

    func presentNativeAlertError(alertTitle title: String = "Error".localized(tableName: "Localizable"), alertMessage message: String) {
        let alertView = SPAlertView(title: title, message: message, preset: .error)
        alertView.duration = 3
        alertView.present()
    }

}
