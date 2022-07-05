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
    func presentAlertError (alertTitle title: String = "Error", alertMessage message: String,
                       buttonTitle titleButton: String = "Dissmiss",
                       alertStyle style: UIAlertAction.Style = .cancel ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    func presentAlertSuccess (alertTitle title: String = "Success", alertMessage message: String,
                              buttonTitle titleButton: String = "Ok",
                              alertStyle style: UIAlertAction.Style = .cancel ) {
               let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
               let action = UIAlertAction(title: titleButton, style: style, handler: nil)
               alertVC.addAction(action)
               present(alertVC, animated: true, completion: nil)
           }
    
    func presentNativeAlertSuccess(alertTitle title: String = "Success", alertMessage message: String) {
        let alertView = SPAlertView(title: title, message: message, preset: .done)
        alertView.duration = 3
        alertView.present()
    }
    
    func presentNativeAlertError(alertTitle title: String = "Error", alertMessage message: String) {
        let alertView = SPAlertView(title: title, message: message, preset: .error)
        alertView.duration = 3
        alertView.present()
    }
    
}
