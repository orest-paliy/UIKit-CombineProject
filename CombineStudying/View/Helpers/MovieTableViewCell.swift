//
//  MoviewTableViewCell.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import UIKit

final class MovieTableViewCell: UITableViewCell{
    static let reuseIdentifier = "movieTableViewCell"
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var movieImage: UIImageView = {
        let imgV = UIImageView()
        imgV.translatesAutoresizingMaskIntoConstraints = false
        imgV.contentMode = .scaleAspectFill
        imgV.layer.cornerRadius = 20
        imgV.clipsToBounds = true
        return imgV
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(){
        contentView.addSubview(movieImage)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            movieImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            movieImage.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            movieImage.heightAnchor.constraint(equalToConstant: 200),
            movieImage.widthAnchor.constraint(equalToConstant: 150),
            
            stackView.leadingAnchor.constraint(equalTo: movieImage.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: movieImage.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: movieImage.bottomAnchor),
        ])
    }
    
    func createLabel(text: String) -> UILabel{
        let lbl = UILabel()
        lbl.text = text
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }
    
    func configure(movie: Movie, imgLoadingService: ImageLoaderService){
        loadImage(imgLoadingService, movie: movie)
        stackView.addArrangedSubview(createLabel(text: movie.title))
        stackView.addArrangedSubview(createLabel(text: movie.overview))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgLoadingTask?.cancel()
        movieImage.image = nil
        stackView.arrangedSubviews.forEach{ subView in
            subView.removeFromSuperview()
        }
    }
    
    //MARK: Networking
    var imgLoadingTask: Task<UIImage, Error>?
    
    func loadImage(_ loadingService: ImageLoaderService, movie: Movie){
        imgLoadingTask = Task{
            let image = try await loadingService.loadImage(by: movie.posterURL)
            movieImage.image = image
            return image
        }
    }
}
