//
//  EmployeeDetails+CoreDataProperties.swift
//  Organization
//
//  Created by Ashish on 01/08/22.
//
//

import Foundation
import CoreData


extension EmployeeDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeDetails> {
        return NSFetchRequest<EmployeeDetails>(entityName: "EmployeeDetails")
    }

    @NSManaged public var address: String?
    @NSManaged public var designation: String?
    @NSManaged public var id: Int64
    @NSManaged public var salary: Double
    @NSManaged public var stocks: String?

}

extension EmployeeDetails : Identifiable {

}
