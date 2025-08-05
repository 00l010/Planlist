
import SwiftUI
import SwiftData

@main
struct PlanListApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(for: Plan.self)
    }
  }
}
