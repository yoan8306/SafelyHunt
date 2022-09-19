//
//  ServicesError.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation

enum ServicesError: Error {
    case createAccountError, emailAlreadyExist, signIn, resetPassword, noAreaRecordedFound, errorDeletingArea, errorTask, listUsersPositions, deleteAccountError, disconnected, distanceTraveled
}

extension ServicesError: LocalizedError {
   public var detail: String {
        switch self {
        case .createAccountError:
            return NSLocalizedString("Error during create account", comment: "Error")
        case .emailAlreadyExist:
            return "This email already exist"
        case .signIn:
            return "Authentification failed"
        case .resetPassword:
            return "Error during reset your password"
        case .noAreaRecordedFound:
            return NSLocalizedString("You doesn't have area recorded. \nClick on \"+\" for add an area", comment: "Error")
        case .errorDeletingArea:
            return  "Error during deleting"
        case .errorTask:
            return "Error during task"
        case .listUsersPositions:
            return "No postions users list found"
        case .deleteAccountError:
            return "Error during delete account"
        case .disconnected :
            return "Error during disconnected."
        case .distanceTraveled:
            return "No distance traveled recorded"
        }
    }
}
