//
//  CoreDataError.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 22.04.2021.
//

import Foundation

enum CoreDataError: String, Error {
    case saveRouteError = "Failed to save route."
    case fetchError = "Enable to fetch data."
    
}
extension CoreDataError: LocalizedError {
    var errorDescription: String? { return NSLocalizedString(rawValue,
                                                             comment: "")}
}
