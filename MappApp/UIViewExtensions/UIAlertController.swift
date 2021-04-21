//
//  UIAlertController.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 21.04.2021.
//

import UIKit

extension UIAlertController {
    static func signOutConfirmation(onConfirm: @escaping () -> Void) -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .default) { _ in onConfirm() }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(ok)
        alert.addAction(cancel)
        
        return alert
    }
    
    static func signUpError() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Sign Up Error.",
                                      message: "Such user already exists.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
    static func passwordChanged() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: nil,
                                      message: "User password changed.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
    static func passwordChangeFail() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Sign Up Error.",
                                      message: "Failed to change password. Please try again.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
    static func userCreated() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: nil,
                                      message: "User created.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
    static func failUserCreate() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Sign Up Error",
                                      message: "Failed to create user. Please try again.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
    static func noSuchUser() -> UIAlertController {
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Login Error.",
                                      message: "There is no such user. Please try again.",
                                      preferredStyle: .alert)
        alert.addAction(ok)
        return alert
    }
    
}
