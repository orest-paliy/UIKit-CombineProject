//
//  CoreDataError.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation

enum AuthError: Error{
    case userNotFound
    case passwordMismatch
    case userAlreadyExists
    case badPasswordConfirmation
    
    var localizedDescription: String{
        switch self {
        case .userNotFound:
            return "User with such email not found"
        case .passwordMismatch:
            return "Password is incorrect"
        case .userAlreadyExists:
            return "User with such email address already exists"
        case .badPasswordConfirmation:
            return "Bad password confirmation"
        }
    }
}
