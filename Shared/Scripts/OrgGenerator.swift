//
//  OrgGenerator.swift
//  Organization (macOS)
//
//  Created by Ashish on 01/08/22.
//

import Foundation

@main
enum OrgGeneratorScript {
    
    private struct Employee: Codable {
        let id: Int
        let name: String
        let designation: String
        let level: Int
        let managerId: Int?
    }
    
    private struct Constants {
        static let randomNamesFile = "/Shared/Scripts/RandomNames.json"
        static let randomDesignationsFile = "/Shared/Scripts/RandomDesignations.json"
        static let orgDummyFile = "/Shared/Scripts/DummyOrg.json"
        static let lowestLevel = 70
        static let highestLevel = 80
        static let maximumReportee = 10
    }
    
    static func main() {
        print("Hello Xcode")
        guard let projectDir = ProcessInfo.processInfo.environment["SRCROOT"],
              let randomNames = try? Array<String>(contentsOfFile: projectDir + Constants.randomNamesFile),
              let randomDesignations = try? Array<String>(contentsOfFile: projectDir + Constants.randomDesignationsFile) else {
            print("Failed to read files")
            return
        }
        
        let employees = generateOrg(randomNames: randomNames, randomDesignations: randomDesignations)
        print(employees.count)
        guard let data = try? JSONEncoder().encode(employees) else {
            return
        }
        let url = URL(fileURLWithPath: projectDir + Constants.orgDummyFile)
        try? data.write(to: url)
    }
    
    // MARK: - Private methods
    
    private static func generateOrg(randomNames: [String], randomDesignations: [String]) -> [Employee] {
        return generateEmployee(randomNames: randomNames, randomDesignations: randomDesignations, manager: nil, highestLevel: Constants.highestLevel)
    }
    
    private static func generateEmployee(randomNames: [String], randomDesignations: [String], manager: Employee?, highestLevel: Int) -> [Employee] {
        var employees: [Employee] = []
        let id = Int.random(in: 1_000_000 ... 100_000_000)
        let firstName = randomNames[Int.random(in: 0 ..< randomNames.count)].split(separator: " ").first
        let lastName = randomNames[Int.random(in: 0 ..< randomNames.count)].split(separator: " ").last
        let name = "\(firstName ?? "") \(lastName ?? "")"
        let designation = randomDesignations[Int.random(in: 0 ..< randomDesignations.count)]
        let level = max(Constants.lowestLevel, Int.random(in: highestLevel - 2 ... highestLevel))
        let employee = Employee(id: id, name: name, designation: designation, level: level, managerId: manager?.id)
        for _ in 0 ..< Int.random(in: 0 ..< Constants.maximumReportee) where level > Constants.lowestLevel {
            let reportee = generateEmployee(randomNames: randomNames, randomDesignations: randomDesignations, manager: employee, highestLevel: level - 1)
            employees.append(contentsOf: reportee)
        }
        employees.append(employee)
        return employees
    }
}

private extension Array where Element == String {
    init?(contentsOfFile file: String) throws {
        let url = URL(fileURLWithPath: file)
        let content = try String(contentsOf: url, encoding: .utf8)
        self = content.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))) }
    }
}
