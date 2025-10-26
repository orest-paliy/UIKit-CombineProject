//
//  MovieService.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import Combine

protocol MovieServiceProtocol{
    func fetchPopularMovies(page: Int) -> AnyPublisher<MovieResult, Error>
}

final class MovieService: MovieServiceProtocol{
    func fetchPopularMovies(page: Int = 1) -> AnyPublisher<MovieResult, Error> {
        var url = URLFormater.getURL(for: .discover)
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
}


