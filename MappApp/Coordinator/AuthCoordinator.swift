//
//  AuthCoordinator.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 18.04.2021.
//

import UIKit


final class AuthCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showLoginModule()
    }
    
    private func showLoginModule() {
        let controller = SignInViewController()
        
        controller.onLogin = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
}

