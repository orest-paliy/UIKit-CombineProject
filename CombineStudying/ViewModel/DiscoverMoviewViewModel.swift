//
//  DiscoverMoviewViewModel.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import Combine

final class DiscoverMoviewViewModel{
    private let movieService: MovieServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var loadedMovies: [Movie] = []
    var page = 1
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func loadMovies(){
        movieService.fetchPopularMovies(page: page)
            .replaceError(with: MovieResult(results: []))
            .sink(receiveValue: {[weak self] moviesContainer in
                if self?.page == 1{
                    self?.loadedMovies = moviesContainer.results
                }else{
                    self?.loadedMovies.append(contentsOf: moviesContainer.results)
                }
            })
            .store(in: &cancellables)
    }
}
