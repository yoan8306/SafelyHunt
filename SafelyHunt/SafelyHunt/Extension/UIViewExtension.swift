//
//  UIViewExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 08/10/2022.
//

import Foundation
import UIKit

extension UIView {
    func startShimmering() {
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let light = UIColor.white.cgColor

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [light, alpha, light]
        gradient.frame = CGRect(
            x: -self.bounds.size.width,
            y: 0, width: 3*self.bounds.size.width,
            height: self.bounds.size.height
        )

        gradient.startPoint = CGPoint(x: 0.0, y: 0.525)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.525)
        gradient.locations = [0.4, 0.5, 0.6]
        self.layer.mask = gradient

        let animation: CABasicAnimation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]

        animation.duration = 2.8
        animation.repeatCount = HUGE
        gradient.add(animation, forKey: "shimmer")
    }

    func stopShimmering() {
        self.layer.mask = nil
    }
}
