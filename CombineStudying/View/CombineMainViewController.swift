//
//  ViewController.swift
//  CombineStudying
//
//  Created by Orest Palii on 24.10.2025.
//

import UIKit
import Combine

class CombineMainViewController: UIViewController {
    //MARK: Dependencies
    let authObserver: AuthObserver
    
    init(authObserver: AuthObserver) {
        self.authObserver = authObserver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI and Lifecycle
    lazy var logOutButton: UIButton = {
        let cnf = UIButton.Configuration.bordered()
        let btn = UIButton(configuration: cnf)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemRed
        btn.setImage(UIImage(systemName: "arrowshape.turn.up.backward.fill"), for: .normal)
        btn.setTitle("Log out", for: .normal)
        
        let action = UIAction{ [weak self] _ in
            self?.authObserver.setUserAuth(active: false)
        }
        btn.addAction(action, for: .touchUpInside)
        
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(logOutButton)
        
        NSLayoutConstraint.activate([
            logOutButton.widthAnchor.constraint(equalToConstant: 150),
            logOutButton.heightAnchor.constraint(equalToConstant: 50),
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
