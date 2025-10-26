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
    
    let currentMovie: Movie
    let imgLoadingService: ImageLoaderService
    
    init(currentMovie: Movie, imgLoadingService: ImageLoaderService) {
        self.currentMovie = currentMovie
        self.imgLoadingService = imgLoadingService
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
}
