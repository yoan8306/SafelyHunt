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
    internal var errorDescription: String? {
        switch self {
        case .createAccountError:
            return "Error during create account"

        case .emailAlreadyExist:
            return "This email already exist"

        case .signIn:
            return "Authentification failed"

        case .resetPassword:
            return "Error during reset your password"

        case .noAreaRecordedFound:
            return "You doesn't have an area recorded. Click on + for add your first area"

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