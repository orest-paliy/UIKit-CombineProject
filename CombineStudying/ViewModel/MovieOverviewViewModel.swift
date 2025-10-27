//
//  MovieOverviewViewModel.swift
//  CombineStudying
//
//  Created by Orest Palii on 26.10.2025.
//

import Combine
import UIKit

final class MovieOverviewViewModel{
    @Published var posterImg: UIImage?
    @Published var backgroundImg: UIImage?
    @Published var isMovieSaved: Bool = false
    @Published var currentMovie: Movie?
    
    let movieId: Int
    let networkMovieService: NetworkMovieServiceProtocol
    let imgLoadingService: ImageLoadingService
    let cdMovieService: CDMovieRepositoryProtocol
    
    init(currentMovie: Movie?, movieId: Int, imgLoadingService: ImageLoadingService, cdMovieService: CDMovieRepositoryProtocol, networkMovieService: NetworkMovieServiceProtocol) {
        self.currentMovie = currentMovie
        self.movieId = movieId
        self.imgLoadingService = imgLoadingService
        self.cdMovieService = cdMovieService
        self.networkMovieService = networkMovieService
        
        checkIfMovieIsSaved()
    }
    
    func validateMovie(){
        if let movie = currentMovie {
            loadPosterAndBackground(movie: movie)
        }else{
            Task{
                currentMovie = try await networkMovieService.fetchMovie(by: movieId)
                loadPosterAndBackground(movie: currentMovie!)
            }
        }
    }
    
    func loadPosterAndBackground(movie: Movie){
        Task{
            async let poster = try? imgLoadingService.loadImage(by: movie.posterURL)
            async let background = try? imgLoadingService.loadImage(by: movie.backImgURL)
            
            let result = await (poster, background)
            self.posterImg = result.0
            self.backgroundImg = result.1
        }
    }
    
    func saveMovie(){
        do{
            let _ = try cdMovieService.save(movie: currentMovie!)
        }catch{
            print(error)
        }
        
        checkIfMovieIsSaved()
    }
    
    func removeMovieFromSaved(){
        do{
            let _ = try cdMovieService.remove(by: movieId)
        }catch{
            print(error)
        }
        
        checkIfMovieIsSaved()
    }
    
    func checkIfMovieIsSaved(){
        isMovieSaved = cdMovieService.isMovieSaved(movieId: movieId)
    }
}
