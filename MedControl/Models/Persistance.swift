//
//  Persistance.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MedControl")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data Store failed: \(error)")
            }
        }
    }
    
}
