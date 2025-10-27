//
//  ProfileViewModel.swift
//  CombineStudying
//
//  Created by Orest Palii on 27.10.2025.
//

import Foundation
import Combine

final class ProfileViewModel{
    let authService: AuthServiceProtocol
    let authObserver: AuthObserver
    let cdMovieService: CDMovieRepositoryProtocol
    let imgLoadingService: ImageLoadingService
    
    init(authService: AuthServiceProtocol, authObserver: AuthObserver ,imgLoadingService: ImageLoadingService, cdMovieService: CDMovieRepositoryProtocol) {
        self.authService = authService
        self.authObserver = authObserver
        self.imgLoadingService = imgLoadingService
        self.cdMovieService = cdMovieService
    }
    
    @Published var savedMovies: [SavedMovie] = []
    
    func loadSavedMovies() {
        guard let user = authService.fetchUserBy(
            email: UserDefaults.standard.string(forKey: AuthObserver.userEmailPath) ?? ""
        )else{
            savedMovies = []
            return
        }
        
        savedMovies = []
        user.savedMovies?.forEach{
            if let movie = $0 as? SavedMovie{
                savedMovies.append(movie)
            }
        }
    }
    
    func logOut(){
        authObserver.setUserAuth(active: false)
    }
    
}
