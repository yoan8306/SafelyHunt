//
//  ServicesError.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation

enum ServicesError: Error {
    case createAccountError,
         emailAlreadyExist,
         signIn,
         noAreaRecordedFound,
         errorDeletingArea,
         errorTask,
         listUsersPositions,
         deleteAccountError,
         disconnected,
         distanceTraveled
}

extension ServicesError: LocalizedError {
    internal var errorDescription: String? {
        switch self {
        case .createAccountError:
            return "Error during create account.".localized(tableName: "LocalizableServicesError")

        case .emailAlreadyExist:
            return "This email already exist.".localized(tableName: "LocalizableServicesError")

        case .signIn:
            return "Authentification failed.".localized(tableName: "LocalizableServicesError")

        case .noAreaRecordedFound:
            return "You doesn't have an area recorded. Click on \"+\" for add your first area.".localized(tableName: "LocalizableServicesError")

        case .errorDeletingArea:
            return  "Error during deleting.".localized(tableName: "LocalizableServicesError")

        case .errorTask:
            return "Error during task.".localized(tableName: "LocalizableServicesError")

        case .listUsersPositions:
            return "No postions users list found".localized(tableName: "LocalizableServicesError")

        case .deleteAccountError:
            return "Error during delete account.".localized(tableName: "LocalizableServicesError")

        case .disconnected :
            return "Error during disconnected.".localized(tableName: "LocalizableServicesError")

        case .distanceTraveled:
            return "No distance traveled recorded.".localized(tableName: "LocalizableServicesError")
        }
    }
}
