//
//  AuthService.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import CoreData

protocol AuthServiceProtocol{
    var cdConfig: CDConfig {get}
    init(config: CDConfig)
    
    func signIn(email: String, password: String) throws -> String
    func logIn(email: String, password: String) throws -> String
    func fetchUserBy(email: String) -> User?
}

