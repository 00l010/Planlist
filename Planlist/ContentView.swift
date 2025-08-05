import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [Plan]
    
    @State private var isAddAlertShowing: Bool = false
    @State private var newTitle: String = ""
    
    @State private var planToEdit: Plan?
    @State private var editedTitle: String = ""
    
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
            .alert("Create a new plan", isPresented: $isAddAlertShowing) {
                TextField("Enter a plan", text: $newTitle)
                Button("Save") {
                    let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    modelContext.insert(Plan(title: trimmed))
                    newTitle = ""
                    simpleHaptic()
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Edit Plan", isPresented: Binding<Bool>(
                get: { planToEdit != nil },
                set: { if !$0 { planToEdit = nil } }
            )) {
                TextField("Edit plan", text: $editedTitle)
                Button("Save") {
                    if let plan = planToEdit {
                        plan.title = editedTitle
                        simpleHaptic()
                    }
                    planToEdit = nil
                }
                Button("Cancel", role: .cancel) {
                    planToEdit = nil
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
