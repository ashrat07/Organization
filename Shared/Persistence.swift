//
//  Persistence.swift
//  Shared
//
//  Created by Ashish on 05/07/22.
//

import CoreData

struct PersistenceController {
    private struct Constants {
        static let seedFile = "DummyOrg"
    }
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Organization")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func syncEmployees() {
        guard let url = Bundle.main.url(forResource: Constants.seedFile, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let employees = try? JSONDecoder().decode([ServerEmployee].self, from: data) else {
            return
        }
        
        var employeeIterator = employees.makeIterator()
//        var employeeIdMap: [Int: Employee] = [:]
        let insertRequest = NSBatchInsertRequest(entity: Employee.entity(), managedObjectHandler: { obj in
            // Stop add item when iterator return nil
            guard let employee = employeeIterator.next() else { return true }
            
            // Convert obj to CustomMO type and fill data to obj
            if let employeeMO = obj as? Employee {
                employeeMO.id = Int32(employee.id)
                let name = employee.name.split(separator: " ")
                employeeMO.firstName = name.first?.trimmingCharacters(in: .whitespacesAndNewlines)
                employeeMO.lastName = name.last?.trimmingCharacters(in: .whitespacesAndNewlines)
                employeeMO.level = Int16(employee.level)
                employeeMO.designation = employee.designation
                if let managerId = employee.managerId {
                    employeeMO.managerId = Int32(managerId)
//                    // Set up relationships
//                    if let manager = employeeIdMap[managerId] {
//                        employeeMO.manager = manager
//                    }
                }
//                employeeIdMap[employee.id] = employeeMO
            }
            
            // Continue adding employee to batch insert request
            return false
        })
        
        let bgContext = container.newBackgroundContext()
        bgContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        bgContext.performAndWait {
            insertRequest.resultType = NSBatchInsertRequestResultType.objectIDs
            let result = try? bgContext.execute(insertRequest) as? NSBatchInsertResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let save = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [container.viewContext])
            }
        }
    }
}
