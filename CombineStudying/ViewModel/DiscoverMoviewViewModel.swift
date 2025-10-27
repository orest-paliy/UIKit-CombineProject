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
    
    @Published var searchPhrase: String = ""
    @Published var loadedMovies: [Movie] = []
    private var loadedMoviesArchive: [Movie] = []
    
    var page = 1
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
        subscribeForSearchChanges()
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
                self?.loadedMoviesArchive = self?.loadedMovies ?? []
            })
            .store(in: &cancellables)
    }
    
    func subscribeForSearchChanges(){
        $searchPhrase
            .removeDuplicates()
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink {[weak self] searchPhrase in
                if searchPhrase.isEmpty{
                    self?.loadedMovies = self?.loadedMoviesArchive ?? []
                }else{
                    Task{
                        self?.loadedMovies = try await self?.movieService.fetch(for: searchPhrase) ?? []
                    }
                }
            }
            .store(in: &cancellables)
    }
}
