//
//  MovieCollectionViewCell.swift
//  CombineStudying
//
//  Created by Orest Palii on 27.10.2025.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier = "movieCollectionViewCell"
    var task: Task<UIImage, Error>?
    lazy var moviePosterIMGV: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 20
        img.clipsToBounds = true
        return img
    }()
    
    lazy var movieTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.backgroundColor = .systemRed
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePosterIMGV.image = nil
        task?.cancel()
    }
    
    private func configureUI(){
        contentView.addSubview(moviePosterIMGV)
        
        NSLayoutConstraint.activate([
            moviePosterIMGV.topAnchor.constraint(equalTo: contentView.topAnchor),
            moviePosterIMGV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            moviePosterIMGV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            moviePosterIMGV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(movie: SavedMovie, imgLoadingService: ImageLoadingService){
        loadImage(movie: movie, imgLoaderService: imgLoadingService)
    }
    
    func loadImage(movie: SavedMovie, imgLoaderService: ImageLoadingService){
        task = Task{
            let image = try await imgLoaderService.loadImage(by: URLFormater.imgBaseURL + (movie.imgURL ?? ""))
            moviePosterIMGV.image = image
            return image
        }
    }
}
