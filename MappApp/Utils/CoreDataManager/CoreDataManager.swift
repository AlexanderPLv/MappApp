//
//  CoreDataManager.swift
//  MappApp
//
//  Created by Alexander Pelevinov on 15.04.2021.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (description, error) in
            
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func fetchCoordinates() -> [Coordinate] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Coordinate>(entityName: "Coordinate")
        let sort = NSSortDescriptor(key: "step", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let coordinates = try context.fetch(fetchRequest)
            return coordinates
        } catch let fetchErr {
            print("Failed to fetch coordinates:", fetchErr)
            return []
        }
    }
    
    func removeAll() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch let deleteErr {
            print("Failed to delete coordinates:", deleteErr)
            // Error Handling
        }
    }
    
}
