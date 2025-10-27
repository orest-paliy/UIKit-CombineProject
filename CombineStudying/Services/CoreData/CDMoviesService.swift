//
//  CDMoviesService.swift
//  CombineStudying
//
//  Created by Orest Palii on 27.10.2025.
//

import Foundation
import CoreData

protocol CDMoviesServiceProtocol{
    func remove(by movieId: Int) throws -> Int
    func save(movie: Movie) throws -> Int
    func isMovieSaved(movieId: Int) -> Bool
    
    init(authService: AuthServiceProtocol)
}

final class CDMoviesService: CDMoviesServiceProtocol{
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol){
        self.authService = authService
    }
    
    func remove(by movieId: Int) throws -> Int{
        //Get and check user data
        guard let userEmail = UserDefaults.standard.string(forKey: "AuthenficatedUserEmail") else { throw AuthError.userLogInError }
        guard let user = authService.fetchUserBy(email: userEmail) else { throw AuthError.userLogInError }
        
        //Removing movie from userSaveds
        guard let movie = try fetchMovie(by: movieId) else{ return movieId }
        user.removeFromSavedMovies(movie)
        
        //Saving viewContext of CD
        try authService.cdConfig.saveContext()
        return movieId
    }
    
    func save(movie: Movie) throws -> Int{
        //Get and check user data
        guard let userEmail = UserDefaults.standard.string(forKey: "AuthenficatedUserEmail") else { throw AuthError.userLogInError }
        guard let user = authService.fetchUserBy(email: userEmail) else { throw AuthError.userLogInError }
        
        //Checking if movie is already presented in CD
        if let movie = try fetchMovie(by: movie.id){
            user.addToSavedMovies(movie)
            movie.addToSavers(user)
        }else{
            let savedMovie = castMovieToCDEntity(movie: movie)
            savedMovie.addToSavers(user)
            user.addToSavedMovies(savedMovie)
        }
        
        //Saving viewContext
        try authService.cdConfig.saveContext()
        return movie.id
    }
    
    func isMovieSaved(movieId: Int) -> Bool {
        guard let userEmail = UserDefaults.standard.string(forKey: "AuthenficatedUserEmail") else { return false }
        guard let user = authService.fetchUserBy(email: userEmail) else { return false }
        
        return user.savedMovies?.contains(where: { element in
            guard let movie = element as? SavedMovie else {return false}
            return movie.id == movieId
        }) ?? false
    }
    
    private func fetchMovie(by id: Int) throws -> SavedMovie?{
        let fetchRequest = SavedMovie.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(id))
        
        let movie = try authService.cdConfig.viewContext.fetch(fetchRequest).first
        return movie
    }
    
    
    private func castMovieToCDEntity(movie: Movie) -> SavedMovie{
        let movieCD = SavedMovie(context: authService.cdConfig.viewContext)
        movieCD.id = Int64(movie.id)
        movieCD.title = movie.title
        movieCD.imgURL = movie.posterURL
        return movieCD
    }
}
