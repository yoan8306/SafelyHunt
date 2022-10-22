//
//  StringExtension.swift
//  SafelyHunt
//
//  Created by Yoan on 21/10/2022.
//

import Foundation

extension String {
    func localized(tableName: String) -> String {
        return NSLocalizedString(
            self,
            tableName: tableName,
            comment: self
        )
    }
}
