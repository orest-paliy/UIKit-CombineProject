//
//  ImageLoader.swift
//  CombineStudying
//
//  Created by Orest Palii on 26.10.2025.
//

import UIKit

final class ImageLoaderService: NSObject {
    
    override init() {
        cache = NSCache()
        super.init()
        
        cache.delegate = self
        cache.countLimit = 30
    }
    
    private let cache: NSCache<NSString, UIImage>
    
    func loadImage(by url: String) async throws -> UIImage{
        if let img = cache.object(forKey: NSString(string: url)){ return img }
        else{
            var responseImg: UIImage
            let url = URL(string: url)!
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data){
                responseImg =  img
            }else{
                responseImg = UIImage(systemName: "photo.badge.exclamationmark.fill")!
            }
            
            cache.setObject(responseImg, forKey: NSString(string: url.absoluteString))
            return responseImg
        }
    }
}

extension ImageLoaderService: NSCacheDelegate{
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let img = obj as? UIImage {
            print(img.size)
        }
    }
}
