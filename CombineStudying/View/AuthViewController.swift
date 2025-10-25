//
//  RegisterViewController.swift
//  CombineStudying
//
//  Created by Orest Palii on 24.10.2025.
//

import UIKit
import Combine

class AuthViewController: UIViewController {
    let viewModel: AuthViewModel
    var cancellables: Set<AnyCancellable> = []
    
    
    init(authObserver: AuthObserver){
        viewModel = AuthViewModel(
            validationService: ValidationService(),
            authService: CDAuthService(),
            authObserver: authObserver,
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    //MARK: UI + Lifecyle
    
    lazy var authTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Welcome!"
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return lbl
    }()
    
    lazy var emailTF: PaddedTextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .tertiarySystemBackground
        tf.placeholder = "Please enter email"
        tf.layer.cornerRadius = 20
        let action = UIAction{[weak self] _ in self?.viewModel.email = tf.text ?? "" }
        tf.addAction(action, for: .editingChanged)
        return tf
    }()
    
    lazy var passwordTF: PaddedTextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .tertiarySystemBackground
        tf.placeholder = "Please enter password"
        tf.layer.cornerRadius = 20
        let action = UIAction{[weak self] _ in self?.viewModel.password = tf.text ?? "" }
        tf.addAction(action, for: .editingChanged)
        return tf
    }()
    
    lazy var passwordConfirmationTF: PaddedTextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .tertiarySystemBackground
        tf.placeholder = "Please confirm password"
        tf.layer.cornerRadius = 20
        let action = UIAction{[weak self] _ in self?.viewModel.passwordConfirmation = tf.text ?? "" }
        tf.addAction(action, for: .editingChanged)
        return tf
    }()
    
    lazy var authButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        let btn = UIButton(configuration: config)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        
        let action = UIAction{[weak self] _ in self?.viewModel.enterInAccount()}
        btn.addAction(action, for: .touchUpInside)
        
        return btn
    }()
    
    lazy var changeAuthStateBtn: UIButton = {
        let configuration = UIButton.Configuration.plain()
        let btn = UIButton(configuration: configuration)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let action = UIAction{[weak self] _ in self?.viewModel.isPageInSignInState.toggle()}
        btn.addAction(action, for: .touchUpInside)
        
        return btn
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 20
        stack.clipsToBounds = true
        return stack
    }()
    
    lazy var errorMessage: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.textColor = .systemRed
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindSubscribers()
    }
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        
        //Stack
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        //Adding items in VStack
        stackView.addArrangedSubview(authTitle)
        stackView.setCustomSpacing(20, after: authTitle)
        stackView.addArrangedSubview(emailTF)
        stackView.addArrangedSubview(passwordTF)
        stackView.addArrangedSubview(authButton)
        stackView.addArrangedSubview(changeAuthStateBtn)
        
        authButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    //MARK: Binding Combine Subscribers
    func bindSubscribers(){
        //Auth button activation
        viewModel
            .$canActivateButton
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink{[weak self] in
                self?.authButton.isEnabled = $0
                self?.viewModel.error = nil
            }
            .store(in: &cancellables)
        
        viewModel.$passwordConfirmation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {[weak self] _ in
                self?.viewModel.error = nil
            })
            .store(in: &cancellables)
        
        //Page state
        viewModel
            .$isPageInSignInState
            .sink(receiveValue: {[weak self] in
                var pageStatusChangingBtnLbl: String
                var enterBtnLbl: String
                
                if let self{
                    if $0{
                        pageStatusChangingBtnLbl = "I already have an account"
                        enterBtnLbl = "Sign in"
                        
                        if let index = self.stackView.arrangedSubviews.firstIndex(of: self.passwordTF) {
                            let insertionIndex = index + 1
                            showPasswordConfirmation(animated: true, insertionIndex: insertionIndex)
                        }
                    }else{
                        pageStatusChangingBtnLbl = "I don't have an account yet"
                        enterBtnLbl = "Log in"
                        
                        hidePasswordConfirmation(animated: true)
                    }
                    
                    self.changeAuthStateBtn.setTitle(pageStatusChangingBtnLbl, for: .normal)
                    self.authButton.setTitle(enterBtnLbl, for: .normal)
                    self.viewModel.error = nil
                }
            })
            .store(in: &cancellables)
        
        //Error reflection
        viewModel
            .$error
            .sink(receiveValue: {[weak self] error in
                if let self{
                    if let error = error{
                        self.stackView.addArrangedSubview(self.errorMessage)
                        self.errorMessage.text = error.localizedDescription
                    }else{
                        self.stackView.removeArrangedSubview(self.errorMessage)
                        self.errorMessage.removeFromSuperview()
                    }
                }
            })
            .store(in: &cancellables)
    }
}

//MARK: Animations
extension AuthViewController{
    func showPasswordConfirmation(animated: Bool, insertionIndex: Int) {
        guard !stackView.arrangedSubviews.contains(passwordConfirmationTF) else { return }
        
        passwordConfirmationTF.isHidden = true
        self.passwordConfirmationTF.alpha = 0
        stackView.insertArrangedSubview(passwordConfirmationTF, at: insertionIndex)
        
        let animations = {
            self.passwordConfirmationTF.isHidden = false
            self.passwordConfirmationTF.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: animations,
                       completion: nil)
    }
    
    func hidePasswordConfirmation(animated: Bool) {
        guard stackView.arrangedSubviews.contains(passwordConfirmationTF) else { return }
        
        let animations = {
            self.passwordConfirmationTF.isHidden = true
            self.passwordConfirmationTF.alpha = 0
            self.view.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { _ in
            self.stackView.removeArrangedSubview(self.passwordConfirmationTF)
            self.passwordConfirmationTF.removeFromSuperview()
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: animations,
                       completion: completion)
    }
    
}

