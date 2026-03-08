import Foundation

protocol SpaceRepository {
    func fetchSpaces(includeArchived: Bool) throws -> [Space]
    func createSpace(title: String, iconName: String?) throws -> (Space, Node)
    func archive(space: Space) throws
}

protocol NodeRepository {
    func fetchChildren(parentID: UUID?, in spaceID: UUID, includeArchived: Bool) throws -> [Node]
    func fetchNode(id: UUID) throws -> Node?
    func createChild(title: String, parent: Node, purpose: String) throws -> Node
    func archive(node: Node, reason: ArchiveReason) throws
    func restore(node: Node) throws
    func update(node: Node, title: String?, purpose: String?, localGuidance: String?) throws
}

protocol ChatRepository {
    func thread(for nodeID: UUID, type: ChatType) throws -> ChatThread
    func messages(threadID: UUID) throws -> [ChatMessage]
    func appendMessage(threadID: UUID, role: MessageRole, content: String) throws -> ChatMessage
}

protocol MemoryRepository {
    func timeline(nodeID: UUID?) throws -> [MemoryEntry]
    func create(nodeID: UUID, kind: MemoryKind, title: String, body: String, sourceType: MemorySourceType, referenceID: UUID?) throws
}

protocol ReminderRepository {
    func reminders(nodeID: UUID?) throws -> [ReminderItem]
    func create(nodeID: UUID, title: String, note: String, dueDate: Date) throws -> ReminderItem
    func toggleComplete(reminder: ReminderItem) throws
}

protocol ApprovalRepository {
    func pendingBundles() throws -> [ApprovalBundle]
    func upsert(bundle: ApprovalBundle) throws
    func setStatus(_ status: ApprovalStatus, bundle: ApprovalBundle) throws
}

protocol CaptureRepository {
    func recentCaptures(limit: Int) throws -> [CaptureItem]
    func save(capture: CaptureItem) throws
}
