//
//  OrganizationDetailView.swift
//  Organization
//
//  Created by Ashish on 01/08/22.
//

import SwiftUI

struct OrganizationDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var employee: Employee
    @State private var showingAlert = false
    
    private var rows: [Employee] {
        var employees = [employee]
        var manager: Employee? = employee.manager
        while let _manager = manager {
            manager = _manager.manager
            employees.append(_manager)
        }
        return employees.reversed()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ForEach(rows) { employee in
                let selectedEmployeeReportee = employee.id == self.employee.id ? employee.reportee : nil
                OrganizationManagerView(employee: employee, isRoot: employee.managerId == 0, reportee: selectedEmployeeReportee)
            }
            .frame(maxWidth: .infinity)
        }
        .toolbar {
            Button(action: removeEmployee) {
                Label("Delete", systemImage: "trash")
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Invalid operation"),
                    message: Text("Cannot remove an employee without a manager."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("\(employee.firstName ?? ""), \(employee.lastName ?? "")")
    }
    
    func removeEmployee() {
        withAnimation {
            guard let managerId = employee.manager?.id, managerId > 0 else {
                showingAlert = true
                return
            }
            
            employee.reportee?.forEach { $0.managerId = managerId }
            viewContext.delete(employee)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct OrganizationManagerView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var employee: Employee
    @State var isRoot = false
    @State var reportee: [Employee]?
    
    var body: some View {
        if !isRoot {
            Divider()
                .frame(width: 1, height: 10, alignment: .center)
                .overlay(.gray)
        }
        OrganizationEmployeeView(employee: employee)
        if let reportee = reportee, !reportee.isEmpty {
            Divider()
                .frame(width: 1, height: 10, alignment: .center)
                .overlay(.gray)
            let sortedReportees = reportee.sorted(by: { $0.firstName ?? "" < $1.firstName ?? "" || $0.lastName ?? "" < $1.lastName ?? "" })
            OrganizationReporteeView(reportee: sortedReportees)
        }
    }
}

struct OrganizationReporteeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var reportee = [Employee]()
    
    var body: some View {
        HStack {
            Divider()
                .frame(width: 10, height: 1, alignment: .center)
                .overlay(.gray)
            Text("Reportee")
                .italic()
            Divider()
                .frame(width: 10, height: 1, alignment: .center)
                .overlay(.gray)
        }
        let gridItemLayout = [GridItem(.adaptive(minimum: 200))]
        LazyVGrid(columns: gridItemLayout) {
            ForEach(reportee) { employee in
                OrganizationEmployeeView(employee: employee)
            }
        }
    }
}

struct OrganizationEmployeeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var employee: Employee
    
    var body: some View {
        VStack {
            Text("\(employee.firstName ?? ""), \(employee.lastName ?? "")")
            Text(employee.designation ?? "")
            Text("L\(employee.level)")
        }
        .frame(width: 160, height: 50, alignment: .center)
        .padding()
        .border(.gray, width: 0.5)
    }
}

struct OrganizationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let employee = Employee()
        OrganizationDetailView(employee: employee)
    }
}
