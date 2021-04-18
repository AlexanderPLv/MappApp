//
//  MapCoordinator.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 18.04.2021.
//

import UIKit


final class MapCoordinator: BaseCoordinator {
    
    var rootController: UINavigationController?
    var onFinishFlow: (() -> Void)?
    
    override func start() {
        showMapModule()
    }
    
    private func showMapModule() {
        let controller = MapViewController()
        
        controller.onLogout = { [weak self] in
            self?.onFinishFlow?()
        }
        
        let rootController = UINavigationController(rootViewController: controller)
        setAsRoot(rootController)
        self.rootController = rootController
    }
    
}


