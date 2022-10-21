//
//  StringExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 21/10/2022.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            comment: self
        )
    }
}
