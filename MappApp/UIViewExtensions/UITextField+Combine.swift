//
//  UITextField+Combine.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 20.04.2021.
//

import UIKit
import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        publisher(for: .editingChanged)
            .map { self.text ?? "" }
            .eraseToAnyPublisher()
    }
}
