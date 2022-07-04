//
//  FirebaseError.swift
//  SafelyHunt
//
//  Created by Yoan on 04/07/2022.
//

import Foundation

enum FirebaseError: Error {
    case createAccountError, emailAlreadyExist
    
    var detail: String {
        switch self {
        case .createAccountError:
            return "Error during create account"
        case .emailAlreadyExist:
            return "This email already exist"
        }
    }
}
