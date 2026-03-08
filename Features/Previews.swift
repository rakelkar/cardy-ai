import SwiftUI
import SwiftData

#if DEBUG
private let previewContainer = PersistenceController.makeContainer(inMemory: true)

@MainActor
private func previewEnvironment() -> AppEnvironment {
    let env = AppEnvironment(context: previewContainer.mainContext)
    try? SampleDataSeeder(spaces: env.spaces, nodes: env.nodes, memories: env.memories, reminders: env.reminders, approvals: env.approvals, captures: env.captures, chats: env.chats).seedIfNeeded()
    return env
}

#Preview("Home") { HomeView(environment: previewEnvironment()) }
#Preview("Spaces") { SpacesView(environment: previewEnvironment()) }
#Preview("Node Detail") {
    let env = previewEnvironment()
    let space = try? env.spaces.fetchSpaces(includeArchived: true).first
    return NavigationStack { NodeDetailView(environment: env, nodeID: space?.rootNodeID ?? UUID()) }
}
#Preview("Chat") {
    let env = previewEnvironment()
    let node = (try? env.nodes.fetchNode(id: (try? env.spaces.fetchSpaces(includeArchived: true).first?.rootNodeID ?? UUID()) ?? UUID()))
    return NavigationStack { ChatView(environment: env, node: node!, type: .manager) }
}
#Preview("Approvals") { ApprovalsView(environment: previewEnvironment()) }
#Preview("Memory") { MemoryView(environment: previewEnvironment()) }
#endif
