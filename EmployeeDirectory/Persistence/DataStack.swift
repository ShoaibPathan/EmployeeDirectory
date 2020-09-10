//
//  DataStack.swift
//  EmployeeDirectory
//
//  Created by Patrick Maltagliati on 9/9/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import CoreData
import Foundation

protocol DataStackProtocol {
    var persistentContainer: NSPersistentContainer { get }
    func saveContext()
}

class DataStack: DataStackProtocol {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EmployeeDirectory")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
