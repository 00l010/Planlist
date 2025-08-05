
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [Plan]
    
    @State private var isAddAlertShowing: Bool = false
    @State private var newTitle: String = ""
    
    @State private var planToEdit: Plan?
    @State private var editedTitle: String = ""
    
    @State private var newDueDate: Date = Date()
    @State private var editedDueDate: Date = Date()
    @State private var isEditingDueDate: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    PlanRowView(
                        plan: plan,
                        onDelete: {
                            modelContext.delete(plan)
                            simpleHaptic()
                        },
                        onEdit: {
                            planToEdit = plan
                            editedTitle = plan.title
                            editedDueDate = plan.dueDate ?? Date() // 🔧
                        },
                        onToggleComplete: {
                            plan.isDone.toggle()
                            simpleHaptic()
                        }
                    )
                }
            }
            .navigationTitle("Plan List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newTitle = ""
                        newDueDate = Date() // 🔧
                        isAddAlertShowing.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                if !plans.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Text("\(plans.count) plan\(plans.count > 1 ? "s" : "")")
                    }
                }
            }

            .sheet(isPresented: $isAddAlertShowing) {
                NavigationStack {
                    Form {
                        Section("Plan Details") {
                            TextField("Enter a plan", text: $newTitle)
                            DatePicker("Due Date", selection: $newDueDate, displayedComponents: .date)
                        }
                        Section {
                            Button("Save") {
                                let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
                                guard !trimmed.isEmpty else { return }
                                modelContext.insert(Plan(title: trimmed, dueDate: newDueDate)) // 🔧
                                newTitle = ""
                                simpleHaptic()
                                isAddAlertShowing = false
                            }
                            Button("Cancel", role: .cancel) {
                                isAddAlertShowing = false
                            }
                        }
                    }
                    .navigationTitle("New Plan")
                }
            }
            
            // 🔧 Edit qilish uchun sheet
            .sheet(item: $planToEdit) { plan in
                NavigationStack {
                    Form {
                        Section("Edit Plan") {
                            TextField("Plan Title", text: $editedTitle)
                            DatePicker("Due Date", selection: $editedDueDate, displayedComponents: .date)
                        }
                        Section {
                            Button("Save") {
                                plan.title = editedTitle
                                plan.dueDate = editedDueDate
                                planToEdit = nil
                                simpleHaptic()
                            }
                            Button("Cancel", role: .cancel) {
                                planToEdit = nil
                            }
                        }
                    }
                    .navigationTitle("Edit Plan")
                }
            }
            
            .overlay {
                if plans.isEmpty {
                    ContentUnavailableView("My Plan List", systemImage: "calendar", description: Text("No plans yet. Add one to get started."))
                }
            }
        }
    }

    private func simpleHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}



#Preview("List with Sample Data") {
  let container = try! ModelContainer(for: Plan.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  
  container.mainContext.insert(Plan(title: "Practice Coding"))
  container.mainContext.insert(Plan(title: "Buy a New Book"))
  container.mainContext.insert(Plan(title: "Go to Gym"))
  container.mainContext.insert(Plan(title: "Walking at Night"))
  container.mainContext.insert(Plan(title: "Make a Positive Impact"))
  
  return ContentView()
    .modelContainer(container)
}

#Preview("Empty List") {
  ContentView()
    .modelContainer(for: Plan.self, inMemory: true)
}
