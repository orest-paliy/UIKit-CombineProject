//
//  MovieOverviewViewControoler.swift
//  CombineStudying
//
//  Created by Orest Palii on 26.10.2025.
//

import Combine
import UIKit

final class MovieOverviewViewController: UIViewController{
    
    //MARK: Dependencies
    let viewModel: MovieOverviewViewModel
    var cancellables: Set<AnyCancellable> = []
    
    init(movie: Movie, imgLoadingService: ImageLoaderService) {
        self.viewModel = MovieOverviewViewModel(currentMovie: movie, imgLoadingService: imgLoadingService)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI and Lifecycle
    private lazy var backgroundImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.translatesAutoresizingMaskIntoConstraints = false
        imgV.clipsToBounds = true
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    private lazy var posterImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.translatesAutoresizingMaskIntoConstraints = false
        imgV.clipsToBounds = true
        imgV.contentMode = .scaleAspectFill
        imgV.layer.cornerRadius = 20
        return imgV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradient(for: backgroundImageView)
    }
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        
        view.addSubview(backgroundImageView)
        view.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 300),
            
            posterImageView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -200),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 300),
            posterImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(){
        viewModel.loadPosterAndBackground()
        
        viewModel.$posterImg
            .receive(on: DispatchQueue.main)
            .sink { [weak posterImageView] image in
                posterImageView?.image = image
            }
            .store(in: &cancellables)
        
        viewModel.$posterImg
            .receive(on: DispatchQueue.main)
            .sink { [weak backgroundImageView] image in
                backgroundImageView?.image = image
            }
            .store(in: &cancellables)
    }
    
    func applyGradient(for imageView: UIImageView){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds
        gradientLayer.colors = [
            UIColor.systemBackground.withAlphaComponent(0).cgColor,
            UIColor.systemBackground.withAlphaComponent(1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        imageView.layer.addSublayer(gradientLayer)
    }
}
