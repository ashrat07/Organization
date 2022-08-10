//
//  OrganzationView.swift
//  Organization
//
//  Created by Ashish on 01/08/22.
//

import SwiftUI
import CoreData

struct OrganzationView: View {
    
    var syncEmployees: (() -> Void)?
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var showingSortOptions = false
    @State private var selection = "None"
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Employee.level, ascending: false)], animation: .default)
    private var employees: FetchedResults<Employee>
    
    init(syncEmployees: (() -> Void)? = nil) {
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Employee.level, ascending: false)]
//        request.fetchLimit = 100
//        request.fetchBatchSize = 100
        _employees = FetchRequest(fetchRequest: request)
        self.syncEmployees = syncEmployees
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(employees) { employee in
                    NavigationLink {
                        OrganizationDetailView(employee: employee)
                    } label: {
                        Text("\(employee.firstName ?? ""), \(employee.lastName ?? "")")
                    }
                }
            }
            .navigationTitle("Organization")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: sortItem) {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .actionSheet(isPresented: $showingSortOptions) {
                        ActionSheet(
                            title: Text("Sort by"),
                            buttons: [
                                .default(Text("Name")) {
                                    employees.nsSortDescriptors = [
                                        NSSortDescriptor(keyPath: \Employee.firstName, ascending: true),
                                        NSSortDescriptor(keyPath: \Employee.lastName, ascending: true)
                                    ]
                                },
                                .default(Text("Level")) {
                                    employees.nsSortDescriptors = [NSSortDescriptor(keyPath: \Employee.level, ascending: false)]
                                },
                                .cancel()
                            ]
                        )
                    }
                    Button(action: refreshItem) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
            Text("Select an item")
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newValue in
            employees.nsPredicate = searchPredicate
        }
    }
    
    var searchPredicate: NSPredicate? {
        guard !searchText.isEmpty else {
            return nil
        }
        
        return NSPredicate(format: "firstName contains %@ OR lastName contains %@", searchText, searchText)
    }
    
    private func refreshItem() {
        withAnimation {
            syncEmployees?()
        }
    }
    
    private func sortItem() {
        showingSortOptions.toggle()
    }
}

struct OrganzationView_Previews: PreviewProvider {
    static var previews: some View {
        OrganzationView()
    }
}
