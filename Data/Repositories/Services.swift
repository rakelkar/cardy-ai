import Foundation
import UserNotifications

struct LocalReminderService: ReminderService {
    func requestPermission() async throws {
        _ = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func schedule(reminder: ReminderItem) async throws -> String {
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.note
        content.sound = .default

        let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
        return identifier
    }

    func cancel(identifier: String) async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

struct LocalSearchService: SearchService {
    let nodeRepository: NodeRepository
    let memoryRepository: MemoryRepository
    let spaceRepository: SpaceRepository

    func search(query: String) throws -> SearchResults {
        guard !query.isEmpty else { return .init(nodes: [], memories: []) }
        let spaces = try spaceRepository.fetchSpaces(includeArchived: true)
        let nodes = try spaces.flatMap { try nodeRepository.fetchChildren(parentID: nil, in: $0.id, includeArchived: true) }
        let matchingNodes = nodes.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.summary.localizedCaseInsensitiveContains(query) || $0.purpose.localizedCaseInsensitiveContains(query) }
        let memories = try memoryRepository.timeline(nodeID: nil).filter { $0.title.localizedCaseInsensitiveContains(query) || $0.body.localizedCaseInsensitiveContains(query) }
        return .init(nodes: matchingNodes, memories: memories)
    }
}

struct MockAIOrchestratorService: AIOrchestratorService {
    let nodeRepository: NodeRepository
    let reminderRepository: ReminderRepository
    let approvalRepository: ApprovalRepository
    let memoryRepository: MemoryRepository

    func sendMessage(thread: ChatThread, node: Node, message: String) async throws -> AIResponse {
        if thread.type == .manager {
            return try await generateManagerResponse(thread: thread, node: node, message: message)
        }
        return try await generateAnalystResponse(thread: thread, node: node, message: message)
    }

    func suggestNodeFromCapture(note: String?) async -> UUID? { nil }

    func summarizeChildren(node: Node) async throws -> String {
        let children = try nodeRepository.fetchChildren(parentID: node.id, in: node.spaceID, includeArchived: false)
        guard !children.isEmpty else { return "No active children yet." }
        return children.map { "• \($0.title): \($0.status.rawValue)" }.joined(separator: "\n")
    }

    func createApprovalBundleIfNeeded(node: Node, thread: ChatThread, message: String) async throws -> ApprovalBundle? {
        let lower = message.lowercased()
        guard lower.contains("recursive") || lower.contains("descendant") || lower.contains("all levels") else { return nil }
        let children = try nodeRepository.fetchChildren(parentID: node.id, in: node.spaceID, includeArchived: false)
        let bundle = ApprovalBundle(nodeID: node.id, threadID: thread.id, requestType: .recurseReadAndSummarize, title: "Recursive scan requested", detail: "Analyst requested descendant scan beyond direct children.", scopeNodeCount: children.count, descendantNodeCount: children.count * 3, willWriteMemory: true, willCreateReminders: false)
        try approvalRepository.upsert(bundle: bundle)
        return bundle
    }

    private func generateManagerResponse(thread: ChatThread, node: Node, message: String) async throws -> AIResponse {
        let lower = message.lowercased()
        if lower.contains("create a child called") {
            let title = message.components(separatedBy: "called").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "New Child"
            _ = try nodeRepository.createChild(title: title, parent: node, purpose: "Created from manager chat")
            try memoryRepository.create(nodeID: node.id, kind: .statusChange, title: "Child created", body: title, sourceType: .chat, referenceID: nil)
            return .init(content: "Added child node \"\(title)\".", createdApproval: nil)
        }
        if lower.contains("remind") {
            let reminder = try reminderRepository.create(nodeID: node.id, title: "Manager chat reminder", note: message, dueDate: .now.addingTimeInterval(86400))
            try memoryRepository.create(nodeID: node.id, kind: .reminderNote, title: reminder.title, body: reminder.note, sourceType: .chat, referenceID: reminder.id)
            return .init(content: "Reminder created for tomorrow. You can edit the due date from Node Detail.", createdApproval: nil)
        }
        if lower.contains("update purpose") {
            try nodeRepository.update(node: node, title: nil, purpose: message.replacingOccurrences(of: "update purpose", with: "").trimmingCharacters(in: .whitespaces), localGuidance: nil)
            return .init(content: "Updated purpose.", createdApproval: nil)
        }
        return .init(content: "Manager noted. Quick actions available: Add Child, Set Reminder, Archive Child, Update Guidance, Update Purpose.", createdApproval: nil)
    }

    private func generateAnalystResponse(thread: ChatThread, node: Node, message: String) async throws -> AIResponse {
        if let approval = try await createApprovalBundleIfNeeded(node: node, thread: thread, message: message) {
            return .init(content: "I need approval for a recursive descendant scan. Check Approvals tab.", createdApproval: approval)
        }
        if message.lowercased().contains("summarize") {
            let summary = try await summarizeChildren(node: node)
            try memoryRepository.create(nodeID: node.id, kind: .summary, title: "Analyst child summary", body: summary, sourceType: .chat, referenceID: nil)
            return .init(content: summary, createdApproval: nil)
        }
        return .init(content: "Analyst can summarize children, compare risks, and request recursive scans.", createdApproval: nil)
    }
}
