//
//  SignInViewController.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 15.04.2021.
//

import UIKit
import CoreData
import Combine

class SignInViewController: UIViewController {
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellable: AnyCancellable?
    
    private var logoView: UIView = {
       let view = UIView()
        view.backgroundColor = .none
        let logoImage = UIImageView(image: #imageLiteral(resourceName: "Logo"))
        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)
        logoImage.centerYInSuperview()
        logoImage.centerXInSuperview()
        return view
    }()
    
    private var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    private var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(trySignUp),
                         for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN IN", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self,
                         action: #selector(handleLogin),
                         for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc private func trySignUp() {
        let context = coreDataManager.persistentContainer.viewContext
        let users = coreDataManager.fetchUsers()
        users.forEach {
            if $0.login == emailTextField.text &&
                $0.password == passwordTextField.text {
                let alert = UIAlertController.signUpError()
                present(alert, animated: true)
            }
            if $0.login == emailTextField.text &&
                $0.password != passwordTextField.text {
                $0.password = passwordTextField.text
                do {
                  try context.save()
                    present(UIAlertController.passwordChanged(),
                            animated: true)
                } catch {
                    present(UIAlertController.passwordChangeFail(),
                            animated: true)
                }
            }
            guard $0.login != emailTextField.text &&
                    $0.password != passwordTextField.text else { return }
            createUser(with: context)
        }
        guard users.count == 0 else { return }
        createUser(with: context)
    }
    
    private func createUser(with context: NSManagedObjectContext) {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User",
                                                          into: context)
        user.setValue(emailTextField.text, forKey: "login")
        user.setValue(passwordTextField.text, forKey: "password")
        do {
          try context.save()
            present(UIAlertController.userCreated(), animated: true)
        } catch {
            present(UIAlertController.failUserCreate(), animated: true)
        }
    }
    
    @objc private func handleLogin() {
        let users = coreDataManager.fetchUsers()
        users.forEach {
            if $0.login == emailTextField.text && $0.password == passwordTextField.text {
                UserDefaults.standard.setValue(true, forKey: "isLogin")
                onLogin?()
            } else {
                present(UIAlertController.noSuchUser(), animated: true)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var onLogin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemPurple
        setupLogoView()
        setupInputFields()
        cancellable = validToSubmit
            .receive(on: RunLoop.main)
            .sink { isValid in
                self.toggleButtons(isValid)
            }
    }
    
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(emailTextField.textPublisher,
                                        passwordTextField.textPublisher)
            .map { login, password in
                !login.isEmpty && !password.isEmpty
            }.eraseToAnyPublisher()
    }
    
    private func toggleButtons(_ isValid: Bool) {
        if isValid {
            [signUpButton, signInButton].forEach {
                $0.isEnabled = true
                $0.backgroundColor = .black
            }
            } else {
                [signUpButton, signInButton].forEach {
                    $0.isEnabled = false
                    $0.backgroundColor = .lightGray
        } } }
    
    fileprivate func setupLogoView() {
            view.addSubview(logoView)
            logoView.anchor(top: view.topAnchor, left: view.leftAnchor,
                            bottom: nil, right: view.rightAnchor,
                            paddingTop: 0,paddingLeft: 0,
                            paddingBottom: 0, paddingRight: 0,
                            width: 0, height: UIScreen.main.bounds.height / 3)
        }
    
    private func setupInputFields() {
        let stackView = VerticalStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            signInButton,
            signUpButton
        ], spacing: 10 )
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoView.bottomAnchor, left: view.leftAnchor,
                         bottom: nil,right: view.rightAnchor,
                         paddingTop: 40, paddingLeft: 40,
                         paddingBottom: 0, paddingRight: 40,
                         width: 0, height: 140)
    }
    
}

