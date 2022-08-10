//
//  Employee+Extension.swift
//  Organization (iOS)
//
//  Created by Ashish on 01/08/22.
//

import Foundation
import CoreData

extension Employee {
    
    var manager: Employee? {
        guard managerId > 0 else {
            return nil
        }
        let fetchRequest = Employee.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: managerId))
        return try? managedObjectContext?.fetch(fetchRequest).first
    }
    
    var reportee: [Employee]? {
        let fetchRequest = Employee.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "managerId == %@", NSNumber(value: id))
        return try? managedObjectContext?.fetch(fetchRequest)
    }
}
