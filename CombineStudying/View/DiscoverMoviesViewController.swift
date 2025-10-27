//
//  ViewController.swift
//  CombineStudying
//
//  Created by Orest Palii on 24.10.2025.
//

import UIKit
import Combine

class DiscoverMoviesViewController: UIViewController {
    //MARK: Dependencies
    let viewModel: DiscoverMoviewViewModel
    let imgLoadingService: ImageLoaderService
    var canvellables: Set<AnyCancellable> = []
    let cdMovieService: CDMoviesServiceProtocol
    
    init(movieService: MovieServiceProtocol, imgLoadingService: ImageLoaderService, cdMovieService: CDMoviesServiceProtocol) {
        self.viewModel = DiscoverMoviewViewModel(movieService: movieService)
        self.imgLoadingService = imgLoadingService
        self.cdMovieService = cdMovieService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI and Lifecycle
    lazy var tableView: UITableView = {
        let tbV = UITableView()
        tbV.translatesAutoresizingMaskIntoConstraints = false
        
        tbV.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        tbV.dataSource = self
        tbV.delegate = self
        
        return tbV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        loadMovies()
        
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func loadMovies(){
        viewModel.$loadedMovies
            .receive(on: RunLoop.main)
            .sink(receiveValue: {[weak self] movies in
                self?.tableView.reloadData()
            })
            .store(in: &canvellables)
        
        viewModel.loadMovies()
    }
}

//MARK: TableView extensions (DataSource + delegate)
extension DiscoverMoviesViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.loadedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
        cell.configure(movie: viewModel.loadedMovies[indexPath.row], imgLoadingService: imgLoadingService)
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: Pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.searchPhrase.isEmpty && indexPath.row == viewModel.loadedMovies.count - 5{
            viewModel.page += 1
            viewModel.loadMovies()
        }
    }
    
    //MARK: onClick
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieOverviewViewController(
            movie: viewModel.loadedMovies[indexPath.row],
            imgLoadingService: imgLoadingService,
            cdMovieService: cdMovieService
            )
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: SearchControllerUpdater
extension DiscoverMoviesViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchPhrase = searchController.searchBar.text ?? ""
    }
}

