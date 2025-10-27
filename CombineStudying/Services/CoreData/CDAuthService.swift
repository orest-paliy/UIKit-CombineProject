//
//  CDAuthService.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import CoreData

final class CDAuthService: AuthServiceProtocol{
    var cdConfig: CDConfig
    
    init(config: CDConfig) {
        self.cdConfig = config
    }
    
    func signIn(email: String, password: String) throws -> String {
        if let _ = fetchUserBy(email: email){ throw AuthError.userAlreadyExists }
        
        let user = User(context: cdConfig.viewContext)
        user.email = email
        user.password = password
        
        try cdConfig.saveContext()
        return email
    }
    
    func logIn(email: String, password: String) throws -> String {
        guard let user = fetchUserBy(email: email) else { throw AuthError.userNotFound }
        
        if user.password != password{
            throw AuthError.passwordMismatch
        }else{
            return email
        }
    }
    
    func fetchUserBy(email: String) -> User?{
        let request = User.fetchRequest()
        let predicate = NSPredicate(format: "email == %@", email)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let user = try? cdConfig.viewContext.fetch(request).first
        return user
    }
}
