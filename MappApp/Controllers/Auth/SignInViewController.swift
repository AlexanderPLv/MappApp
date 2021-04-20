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
    
    @Published private var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    @Published private var passwordTextField: UITextField = {
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
        button.isEnabled = true
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
                showAlert(title: "Sign Up Error.",
                          with: "Such user already exists.")
            }
            if $0.login == emailTextField.text &&
                $0.password != passwordTextField.text {
                $0.password = passwordTextField.text
                do {
                  try context.save()
                    showAlert(title: "Success.", with: "User password changed.")
                } catch {
                    showAlert(title: "Sign Up Error",
                              with: "Failed to change password. Please try again.")
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
            showAlert(title: "Success.", with: "User created.")
        } catch {
            showAlert(title: "Sign Up Error",
                      with: "Failed to create user. Please try again.")
        }
    }
    
    @objc private func handleLogin() {
        let users = coreDataManager.fetchUsers()
        users.forEach {
            if $0.login == emailTextField.text && $0.password == passwordTextField.text {
                UserDefaults.standard.setValue(true, forKey: "isLogin")
                onLogin?()
            } else {
                showAlert(title: "Login Error.", with: "There is no such user. Please try again.")
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
                if isValid {
                    self.signInButton.isEnabled = true
                    self.signUpButton.isEnabled = true
                    self.signInButton.backgroundColor = .black
                    self.signUpButton.backgroundColor = .black
                } else {
                    self.signInButton.isEnabled = false
                    self.signUpButton.isEnabled = false
                    self.signInButton.backgroundColor = .lightGray
                    self.signUpButton.backgroundColor = .lightGray
                }
            }
    }
    
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(emailTextField.textPublisher,
                                        passwordTextField.textPublisher)
            .map { login, password in
                !login.isEmpty && !password.isEmpty
            }.eraseToAnyPublisher()
    }
    
    fileprivate func setupLogoView() {
            view.addSubview(logoView)
            logoView.anchor(top: view.topAnchor, left: view.leftAnchor,
                            bottom: nil, right: view.rightAnchor,
                            paddingTop: 0,paddingLeft: 0,
                            paddingBottom: 0, paddingRight: 0,
                            width: 0, height: view.frame.height / 3)
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
    
    private func showAlert(title: String, with message: String) {
        let alertController = UIAlertController(title: title,
                                                message: (message),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok",
                                                style: .cancel))
        present(alertController, animated: true)
    }
    
}

