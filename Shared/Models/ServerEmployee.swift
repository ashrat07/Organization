//
//  ServerEmployee.swift
//  Organization (iOS)
//
//  Created by Ashish on 01/08/22.
//

import Foundation

struct ServerEmployee: Codable {
    let id: Int
    let name: String
    let designation: String
    let level: Int
    let managerId: Int?
}
