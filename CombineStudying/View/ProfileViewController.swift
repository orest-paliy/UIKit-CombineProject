//
//  ProfileViewController.swift
//  CombineStudying
//
//  Created by Orest Palii on 27.10.2025.
//

import Combine
import UIKit

final class ProfileViewController: UIViewController{
    
    //MARK: Scroll direction tracking
    private var lastContentOffset: CGFloat = 0
    
    //MARK: Dependencies
    let viewModel: ProfileViewModel
    let networkMovieService: NetworkMovieServiceProtocol
    var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ProfileViewModel, networkMovieService: NetworkMovieServiceProtocol){
        self.viewModel = viewModel
        self.networkMovieService = networkMovieService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    var profileCardView: UIImageView = {
       let pV = UIImageView()
        pV.translatesAutoresizingMaskIntoConstraints = false
        pV.backgroundColor = .secondarySystemBackground
        pV.layer.cornerRadius = 20
        pV.clipsToBounds = true
        return pV
    }()
    
    //MARK: UI + Lifecycle
    var profileIcon: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = .tertiarySystemBackground
        img.tintColor = .systemFill
        img.layer.cornerRadius = 20
        img.clipsToBounds = true
        
        img.contentMode = .center
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        img.image = UIImage(systemName: "person", withConfiguration: config)
        
        return img
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cellWidth = view.frame.width / 2 - 18
        let cellHeight = cellWidth * 1.5
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        
        let collV = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collV.translatesAutoresizingMaskIntoConstraints = false
        collV.showsVerticalScrollIndicator = false
        
        collV.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        collV.dataSource = self
        collV.delegate = self
        
        return collV
    }()
    
    var profileName: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = UserDefaults.standard.string(forKey: AuthObserver.userEmailPath)
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    lazy var logOutButton: UIButton = {
        let configuration = UIButton.Configuration.bordered()
        let btn = UIButton(configuration: configuration)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let action = UIAction(
            handler: {[weak self] _ in
                let alert = UIAlertController(title: "Want to log out?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self?.viewModel.logOut()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self?.present(alert, animated: true)
            }
        )
        
        btn.addAction(action, for: .touchUpInside)
        
        btn.backgroundColor = .systemRed
        btn.setTitle("Log out", for: .normal)
        btn.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        
        return btn
    }()
    
    lazy var vStack: UIStackView = {
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.spacing = 6
        vStack.alignment = .center
        return vStack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    private func configureUI(){
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        
        view.addSubview(profileCardView)
        
        NSLayoutConstraint.activate([
            profileCardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileCardView.heightAnchor.constraint(equalToConstant: 84),
        ])
        
        profileCardView.addSubview(profileIcon)
        profileCardView.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            profileIcon.topAnchor.constraint(equalTo: profileCardView.topAnchor, constant: 12),
            profileIcon.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 12),
            profileIcon.widthAnchor.constraint(equalToConstant: 60),
            profileIcon.heightAnchor.constraint(equalToConstant: 60),
            
            vStack.leadingAnchor.constraint(equalTo: profileIcon.trailingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -12),
            vStack.centerYAnchor.constraint(equalTo: profileIcon.centerYAnchor)
        ])
        
        vStack.addArrangedSubview(profileName)
        vStack.addArrangedSubview(logOutButton)
        
    }
    
    private func configure(){
        viewModel.loadSavedMovies()
        
        viewModel.$savedMovies
            .sink {[weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.savedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? MovieCollectionViewCell {
            cell.configure(movie: viewModel.savedMovies[indexPath.row], imgLoadingService: viewModel.imgLoadingService)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            MovieOverviewViewController(
                movie: nil,
                movieId: Int(viewModel.savedMovies[indexPath.row].id),
                imgLoadingService: viewModel.imgLoadingService,
                cdMovieService: viewModel.cdMovieService,
                networkMovieService: networkMovieService
            ),
            animated: true
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > lastContentOffset && currentOffset - lastContentOffset > 20{
            hideProfileMenu()
        } else if currentOffset < lastContentOffset && lastContentOffset - currentOffset > 20{
            showProfileMenu()
        }
        
        lastContentOffset = currentOffset
    }
}

extension ProfileViewController{
    private func hideProfileMenu(){
        UIView.animate(withDuration: 0.3, delay: 0, animations: {[weak self] in
            self?.profileCardView.alpha = 0
        })
    }
    
    private func showProfileMenu(){
        UIView.animate(withDuration: 0.3, delay: 0, animations: {[weak self] in
            self?.profileCardView.transform = .identity
            self?.profileCardView.alpha = 1
        })
    }
}
