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
    private let authKeyPath = "isUserAithentificated"
    init(){
        checkIfUserIsAuthentificated()
    }
    
    func setUserAuth(active: Bool){
        UserDefaults.standard.set(active, forKey: authKeyPath)
        checkIfUserIsAuthentificated()
    }
    
    private func checkIfUserIsAuthentificated(){
        isUserAuthentificated = UserDefaults.standard.bool(forKey: authKeyPath)
    }
}
