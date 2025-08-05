import SwiftUI

struct PlanRowView: View {
    @Bindable var plan: Plan
    var onDelete: () -> Void
    var onEdit: () -> Void
    var onToggleComplete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                onToggleComplete()
            }) {
                Image(systemName: plan.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(plan.isDone ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title)
                    .strikethrough(plan.isDone)
                    .foregroundStyle(plan.isDone ? .secondary : .primary)
                    .animation(.easeInOut, value: plan.isDone)
                
                if let dueDate = plan.dueDate {
                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 5)
            
            Spacer()
        }
        .padding(.vertical, 5)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
        .swipeActions(edge: .leading) {
            Button("Edit") {
                onEdit()
            }
            .tint(.blue)
        }
    }
}
