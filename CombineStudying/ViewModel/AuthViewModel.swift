//
//  AuthViewModel.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Combine
import Foundation

final class AuthViewModel{
    
    private var validationService: ValidationService
    private var authService: AuthServiceProtocol
    private var authObserver: AuthObserver
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var canActivateButton: Bool = false
    @Published var isPageInSignInState: Bool = true
    @Published var error: AuthError?
    
    init(validationService: ValidationService, authService: AuthServiceProtocol, authObserver: AuthObserver) {
        self.validationService = validationService
        self.authService = authService
        self.authObserver = authObserver
        
        $email.combineLatest($password, {(email, password) in
            return validationService.validate(email: email) && validationService.validate(password: password)
        })
        .assign(to: &$canActivateButton)
    }
    
    func enterInAccount(){
        do{
            var receivedEmail: String?
            if isPageInSignInState{
                receivedEmail = try authService.signIn(email: email.lowercased(), password: password.lowercased())
            }else{
                receivedEmail = try authService.logIn(email: email.lowercased(), password: password.lowercased())
            }
            
            if let _ = receivedEmail{
                authObserver.setUserAuth(active: true)
            }
        }catch{
            print(error)
            if let error = error as? AuthError{
                self.error = error
            }
        }
    }
}

