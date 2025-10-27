//
//  AuthObserver.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import Combine

final class AuthObserver{
    @Published var isUserAuthentificated: Bool = false
    private var userEmail: String?
    
    private let authKeyPath = "isUserAithenficated"
    static let userEmailPath = "AuthenficatedUserEmail"
    
    init(){
        checkIfUserIsAuthentificated()
    }
    
    func setUserAuth(active: Bool, userEmail: String = UserDefaults.standard.string(forKey: userEmailPath) ?? ""){
        UserDefaults.standard.set(active, forKey: authKeyPath)
        UserDefaults.standard.set(userEmail, forKey: AuthObserver.userEmailPath)
        checkIfUserIsAuthentificated()
    }
    
    private func checkIfUserIsAuthentificated(){
        isUserAuthentificated = UserDefaults.standard.bool(forKey: authKeyPath)
        if isUserAuthentificated{
            userEmail = UserDefaults.standard.string(forKey: AuthObserver.userEmailPath)
        }
    }
}
