//
//  OrganizationApp.swift
//  Shared
//
//  Created by Ashish on 05/07/22.
//

import SwiftUI

@main
struct OrganizationApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                OrganzationView(syncEmployees: persistenceController.syncEmployees)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Organization", systemImage: "person.3.fill")
                    }
                
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Timestamp", systemImage: "square.and.pencil")
                    }
            }
        }
    }
}
