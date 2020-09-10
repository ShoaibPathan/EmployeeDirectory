//
//  DataStackProtocolMock.swift
//  EmployeeDirectoryTests
//
//  Created by Patrick Maltagliati on 9/9/20.
//  Copyright © 2020 Patrick Maltagliati. All rights reserved.
//

import CoreData
import Foundation

class DataStackProtocolMock: DataStackProtocol {
    lazy var persistentContainer: NSPersistentContainer = {
        let container: NSPersistentContainer
        if let managedObjectModel = self.managedObjectModel {
            container = NSPersistentContainer(name: "EmployeeDirectory",
                                              managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentContainer(name: "EmployeeDirectory")
        }
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))])
    }()

    func saveContext() {}
}
