//
//  URLFormater.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation

final class URLFormater{
    private static let baseURL = "https://api.themoviedb.org/3/"
    static let imgBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    static func getURL(for endpoint: Endpoint, movieId: Int?) -> URL{
        var url: URL
        if let movieId{
            url = URL(string: baseURL + endpoint.rawValue + movieId.description)!
        }else{
            url = URL(string: baseURL + endpoint.rawValue)!
        }
        url.append(queryItems: [
            URLQueryItem(name: "api_key", value: Secrets.movieLibraryAPIKey)
        ])
        return url
    }
    
    enum Endpoint: String{
        case discover = "discover/movie"
        case search = "search/movie"
        case getById = "movie/"
    }
}
