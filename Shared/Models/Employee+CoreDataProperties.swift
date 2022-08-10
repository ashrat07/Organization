//
//  Employee+CoreDataProperties.swift
//  Organization (iOS)
//
//  Created by Ashish on 14/08/22.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var designation: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var lastName: String?
    @NSManaged public var level: Int16
    @NSManaged public var managerId: Int32

}

extension Employee : Identifiable {

}
