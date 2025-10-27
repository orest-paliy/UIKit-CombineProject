//
//  MovieService.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import Combine

protocol NetworkMovieServiceProtocol{
    func fetchPopularMovies(page: Int) -> AnyPublisher<MovieResult, Error>
    func fetch(for searchPhrase: String) async throws -> [Movie]
    func fetchMovie(by id: Int) async throws -> Movie
}

final class NetworkMovieService: NetworkMovieServiceProtocol{
    func fetchPopularMovies(page: Int = 1) -> AnyPublisher<MovieResult, Error> {
        var url = URLFormater.getURL(for: .discover, movieId: nil)
        url.append(queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
        return URLSession
            .shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: MovieResult.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    func fetch(for searchPhrase: String) async throws -> [Movie] {
        var url = URLFormater.getURL(for: .search, movieId: nil)
        url.append(queryItems: [
            URLQueryItem(name: "query", value: searchPhrase)
        ])
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let moviesResult = try? JSONDecoder().decode(MovieResult.self, from: data)
        
        return moviesResult?.results ?? []
    }
    
    func fetchMovie(by id: Int) async throws -> Movie {
        let url = URLFormater.getURL(for: .getById, movieId: id)
        let (data, _) = try await URLSession.shared.data(from: url)
        let movie = try JSONDecoder().decode(Movie.self, from: data)
        return movie
    }
}


