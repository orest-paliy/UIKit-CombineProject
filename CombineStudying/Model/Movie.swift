//
//  Moview.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation

struct Movie: Codable{
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let backImgPath: String
    
    enum CodingKeys: String, CodingKey{
        case id = "id"
        case title = "original_title"
        case overview = "overview"
        case posterPath = "poster_path"
        case backImgPath = "backdrop_path"
    }
    
    var posterURL: String{
        URLFormater.imgBaseURL + posterPath
    }
    
    var backImgURL: String{
        URLFormater.imgBaseURL + backImgPath
    }
}

struct MovieResult: Codable{
    var results: [Movie]
}
