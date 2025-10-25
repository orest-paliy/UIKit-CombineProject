//
//  Secrets.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation

struct Secrets{
    lazy var movieLibraryAPIKey: String = {
        guard let url = Bundle.main.url(forResource: "MovieLibraryAPIKey", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) as? [String: Any],
              let key = dict["MOVIE_LIBRARY_API_KEY"] as? String
        else{fatalError("API key not found")}
        return key
    }()
}
