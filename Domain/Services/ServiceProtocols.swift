import Foundation

struct AIResponse {
    let content: String
    let createdApproval: ApprovalBundle?
}

protocol AIOrchestratorService {
    func sendMessage(thread: ChatThread, node: Node, message: String) async throws -> AIResponse
    func suggestNodeFromCapture(note: String?) async -> UUID?
    func summarizeChildren(node: Node) async throws -> String
    func createApprovalBundleIfNeeded(node: Node, thread: ChatThread, message: String) async throws -> ApprovalBundle?
}

protocol ReminderService {
    func requestPermission() async throws
    func schedule(reminder: ReminderItem) async throws -> String
    func cancel(identifier: String) async
}

protocol SearchService {
    func search(query: String) throws -> SearchResults
}

struct SearchResults {
    var nodes: [Node]
    var memories: [MemoryEntry]
}
