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
    
    init(movie: Movie?, movieId: Int, imgLoadingService: ImageLoadingService, cdMovieService: CDMovieRepositoryProtocol, networkMovieService: NetworkMovieServiceProtocol) {
        self.viewModel = MovieOverviewViewModel(
            currentMovie: movie,
            movieId: movieId,
            imgLoadingService: imgLoadingService,
            cdMovieService: cdMovieService,
            networkMovieService: networkMovieService
        )
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
    
    lazy var movieDescTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 20
        
        btn.addAction(UIAction{[weak viewModel] _ in
            if viewModel?.isMovieSaved ?? false {
                viewModel?.removeMovieFromSaved()
            }else{
                viewModel?.saveMovie()
            }
        }, for: .touchUpInside)
        
        return btn
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
        view.addSubview(movieDescTitle)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 300),
            
            posterImageView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -180),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 300),
            posterImageView.widthAnchor.constraint(equalToConstant: 200),
            
            movieDescTitle.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            movieDescTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            movieDescTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(){
        viewModel.validateMovie()
        
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
        
        viewModel.$isMovieSaved
            .sink(receiveValue: {[weak self] isSaved in
                self?.saveButton.backgroundColor = isSaved ? .systemRed : .systemGreen
                self?.saveButton.setTitle(isSaved ? "Remove" : "Save", for: .normal)
            })
            .store(in: &cancellables)
        
        viewModel.$currentMovie
            .sink { [weak self] movie in
                if let movie{
                    self?.navigationItem.title = movie.title
                    self?.movieDescTitle.text = movie.overview
                }
            }
            .store(in: &cancellables)
    }
    
    func applyGradient(for imageView: UIImageView){
        if imageView.layer.sublayers == nil{
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
}
