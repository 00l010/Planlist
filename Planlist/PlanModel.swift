
import Foundation
import SwiftData

@Model
class Plan {
  var title: String
  var isDone: Bool
  var dueDate: Date?           
  var priority: Priority
  var category: String

  init(title: String, isDone: Bool = false, dueDate: Date? = nil, priority: Priority = .medium, category: String = "General") {
    self.title = title
    self.isDone = isDone
    self.dueDate = dueDate
    self.priority = priority
    self.category = category
  }
}

enum Priority: String, CaseIterable, Codable {
  case low, medium, high
}
