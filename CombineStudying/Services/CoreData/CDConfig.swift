//
//  CoreDataConfig.swift
//  CombineStudying
//
//  Created by Orest Palii on 25.10.2025.
//

import Foundation
import CoreData

final class CDConfig{
    private let container = NSPersistentContainer(name: "Auth")
    var viewContext: NSManagedObjectContext{
        container.viewContext
    }
    
    init(){
        container.loadPersistentStores { _, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func saveContext() throws{
        do{
            try viewContext.save()
        }catch{
            viewContext.rollback()
            throw error
        }
    }
}
