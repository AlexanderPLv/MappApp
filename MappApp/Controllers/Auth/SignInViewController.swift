//
//  SignInViewController.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 15.04.2021.
//

import UIKit

class SignInViewController: UIViewController {
    
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
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
   private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signInButton.isEnabled = true
            signInButton.backgroundColor = .black
        } else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = .lightGray
        }
    }
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(goToSignUp),
                         for: .touchUpInside)
        button.isEnabled = true
        
        return button
    }()
    
    @objc private func goToSignUp() {
       
    }
    
    lazy var signInButton: UIButton = {
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
    
    @objc private func handleLogin() {
        UserDefaults.standard.setValue(true, forKey: "isLogin")
        onLogin?()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var onLogin: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemPurple
        view.addSubview(logoView)
        logoView.anchor(top: view.topAnchor, left: view.leftAnchor,
                        bottom: nil, right: view.rightAnchor,
                        paddingTop: 0,paddingLeft: 0,
                        paddingBottom: 0, paddingRight: 0,
                        width: 0, height: view.frame.height / 3)
        setupInputFields()
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

