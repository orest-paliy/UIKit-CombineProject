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
    
    let currentMovie: Movie
    let imgLoadingService: ImageLoaderService
    let cdMovieService: CDMoviesServiceProtocol
    
    init(currentMovie: Movie, imgLoadingService: ImageLoaderService, cdMovieService: CDMoviesServiceProtocol) {
        self.currentMovie = currentMovie
        self.imgLoadingService = imgLoadingService
        self.cdMovieService = cdMovieService
        
        checkIfMovieIsSaved()
    }
    
    func loadPosterAndBackground(){
        Task{
            async let poster = try? imgLoadingService.loadImage(by: currentMovie.posterURL)
            async let background = try? imgLoadingService.loadImage(by: currentMovie.backImgURL)
            
            let result = await (poster, background)
            self.posterImg = result.0
            self.backgroundImg = result.1
        }
    }
    
    func saveMovie(){
        do{
            let _ = try cdMovieService.save(movie: currentMovie)
        }catch{
            print(error)
        }
        
        checkIfMovieIsSaved()
    }
    
    func removeMovieFromSaved(){
        do{
            let _ = try cdMovieService.remove(by: currentMovie.id)
        }catch{
            print(error)
        }
        
        checkIfMovieIsSaved()
    }
    
    func checkIfMovieIsSaved(){
        isMovieSaved = cdMovieService.isMovieSaved(movieId: currentMovie.id)
    }
}
