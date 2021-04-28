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
    
    func fetchUsers() -> [User] {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try context.fetch(fetchRequest)
            return users
        } catch let fetchErr {
            print("Failed to fetch users:", fetchErr)
            return []
        }
    }
    
    func saveCurrentRoute(with steps: [CLLocationCoordinate2D]) throws {
        let context = persistentContainer.viewContext
        for (index, step) in steps.enumerated() {
            let coordinate = Coordinate(context: context)
            coordinate.step = Int32(index)
            coordinate.latitude = step.latitude
            coordinate.longitude = step.longitude
            do {
              try context.save()
            } catch {
               throw CoreDataError.saveRouteError
            }
        }
    }
    
    func fetchCurrentUser(with context: NSManagedObjectContext) throws -> User? {
        guard let login = UserDefaults.standard.string(forKey: "currentLogin") else {
            return nil
        }
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        let predicate = NSPredicate(format: "login = %@", login)
        fetchRequest.predicate = predicate
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            throw CoreDataError.fetchError
        }
    }
    
    func saveCurrentPhoto(with data: Data?) {
        guard let data = data else { return }
        let context = persistentContainer.viewContext
        do {
            let user = try fetchCurrentUser(with: context)
            if let user = user {
                user.photo?.image = data
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func removeAllCoordinates() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Coordinate")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch let deleteErr {
            print("Failed to delete coordinates:", deleteErr)
        }
    }
    
}
