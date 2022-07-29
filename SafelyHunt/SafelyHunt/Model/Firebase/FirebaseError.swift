//
//  FirebaseError.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation

enum FirebaseError: Error {
    case createAccountError, emailAlreadyExist,signIn, resetPassword, noAreaRecordedFound
    
    var detail: String {
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
            return "You doesn't have area recorded. \nClick on + for add an area"
        }
    }
}
