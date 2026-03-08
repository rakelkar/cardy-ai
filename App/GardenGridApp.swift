import SwiftUI
import SwiftData

@main
struct GardenGridApp: App {
    private let container = PersistenceController.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .modelContainer(container)
        }
    }
}

struct RootTabView: View {
    @Environment(\.modelContext) private var context
    @State private var environment: AppEnvironment?

    var body: some View {
        Group {
            if let environment {
                TabView {
                    HomeView(environment: environment)
                        .tabItem { Label("Home", systemImage: "house") }
                    SpacesView(environment: environment)
                        .tabItem { Label("Spaces", systemImage: "square.grid.2x2") }
                    CaptureView(environment: environment)
                        .tabItem { Label("Capture", systemImage: "camera") }
                    ApprovalsView(environment: environment)
                        .tabItem { Label("Approvals", systemImage: "checkmark.shield") }
                    MemoryView(environment: environment)
                        .tabItem { Label("Memory", systemImage: "clock.arrow.circlepath") }
                }
            } else {
                ProgressView()
                    .task { self.environment = AppEnvironment(context: context) }
            }
        }
    }
}
