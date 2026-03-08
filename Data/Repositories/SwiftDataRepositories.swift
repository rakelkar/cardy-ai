import Foundation
import SwiftData

@Observable
final class SwiftDataStore {
    let context: ModelContext
    init(context: ModelContext) { self.context = context }
    func save() throws { try context.save() }
}

struct SwiftDataSpaceRepository: SpaceRepository {
    let store: SwiftDataStore

    func fetchSpaces(includeArchived: Bool) throws -> [Space] {
        let descriptor = FetchDescriptor<Space>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try store.context.fetch(descriptor).filter { includeArchived || !$0.isArchived }
    }

    func createSpace(title: String, iconName: String?) throws -> (Space, Node) {
        let space = Space(title: title, iconName: iconName)
        let root = Node(title: "\(title) Root", summary: "Top-level planning node", purpose: "Organize this space", spaceID: space.id)
        space.rootNodeID = root.id
        store.context.insert(space)
        store.context.insert(root)
        try store.save()
        return (space, root)
    }

    func archive(space: Space) throws {
        space.isArchived = true
        space.updatedAt = .now
        try store.save()
    }
}

struct SwiftDataNodeRepository: NodeRepository {
    let store: SwiftDataStore

    func fetchChildren(parentID: UUID?, in spaceID: UUID, includeArchived: Bool) throws -> [Node] {
        let descriptor = FetchDescriptor<Node>(sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.updatedAt, order: .reverse)])
        return try store.context.fetch(descriptor).filter {
            $0.parentNodeID == parentID && $0.spaceID == spaceID && (includeArchived || !$0.isArchived)
        }
    }

    func fetchNode(id: UUID) throws -> Node? {
        let descriptor = FetchDescriptor<Node>()
        return try store.context.fetch(descriptor).first(where: { $0.id == id })
    }

    func createChild(title: String, parent: Node, purpose: String) throws -> Node {
        let existing = try fetchChildren(parentID: parent.id, in: parent.spaceID, includeArchived: true)
        let node = Node(title: title, summary: "", purpose: purpose, parentNodeID: parent.id, spaceID: parent.spaceID, inheritedGuidance: parent.effectiveGuidanceCache, effectiveGuidanceCache: [parent.effectiveGuidanceCache, parent.localGuidance].filter { !$0.isEmpty }.joined(separator: "\n"), sortOrder: existing.count)
        store.context.insert(node)
        try store.save()
        return node
    }

    func archive(node: Node, reason: ArchiveReason) throws {
        node.isArchived = true
        node.archivedReasonRaw = reason.rawValue
        node.statusRaw = NodeStatus.archived.rawValue
        node.updatedAt = .now
        try store.save()
    }

    func restore(node: Node) throws {
        node.isArchived = false
        node.archivedReasonRaw = nil
        node.statusRaw = NodeStatus.active.rawValue
        node.updatedAt = .now
        try store.save()
    }

    func update(node: Node, title: String?, purpose: String?, localGuidance: String?) throws {
        if let title { node.title = title }
        if let purpose { node.purpose = purpose }
        if let localGuidance {
            node.localGuidance = localGuidance
            node.effectiveGuidanceCache = [node.inheritedGuidance, localGuidance].filter { !$0.isEmpty }.joined(separator: "\n")
        }
        node.updatedAt = .now
        try store.save()
    }
}

struct SwiftDataChatRepository: ChatRepository {
    let store: SwiftDataStore

    func thread(for nodeID: UUID, type: ChatType) throws -> ChatThread {
        let descriptor = FetchDescriptor<ChatThread>()
        if let existing = try store.context.fetch(descriptor).first(where: { $0.nodeID == nodeID && $0.typeRaw == type.rawValue }) {
            return existing
        }
        let thread = ChatThread(nodeID: nodeID, type: type, title: "\(type.rawValue.capitalized) Chat")
        store.context.insert(thread)
        try store.save()
        return thread
    }

    func messages(threadID: UUID) throws -> [ChatMessage] {
        let descriptor = FetchDescriptor<ChatMessage>(sortBy: [SortDescriptor(\.createdAt)])
        return try store.context.fetch(descriptor).filter { $0.threadID == threadID }
    }

    func appendMessage(threadID: UUID, role: MessageRole, content: String) throws -> ChatMessage {
        let msg = ChatMessage(threadID: threadID, role: role, content: content)
        store.context.insert(msg)
        try store.save()
        return msg
    }
}

struct SwiftDataMemoryRepository: MemoryRepository {
    let store: SwiftDataStore

    func timeline(nodeID: UUID?) throws -> [MemoryEntry] {
        let descriptor = FetchDescriptor<MemoryEntry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try store.context.fetch(descriptor).filter { nodeID == nil || $0.nodeID == nodeID }
    }

    func create(nodeID: UUID, kind: MemoryKind, title: String, body: String, sourceType: MemorySourceType, referenceID: UUID?) throws {
        store.context.insert(MemoryEntry(nodeID: nodeID, kind: kind, title: title, body: body, sourceType: sourceType, sourceReferenceID: referenceID))
        try store.save()
    }
}

struct SwiftDataReminderRepository: ReminderRepository {
    let store: SwiftDataStore

    func reminders(nodeID: UUID?) throws -> [ReminderItem] {
        let descriptor = FetchDescriptor<ReminderItem>(sortBy: [SortDescriptor(\.dueDate)])
        return try store.context.fetch(descriptor).filter { nodeID == nil || $0.nodeID == nodeID }
    }

    func create(nodeID: UUID, title: String, note: String, dueDate: Date) throws -> ReminderItem {
        let reminder = ReminderItem(nodeID: nodeID, title: title, note: note, dueDate: dueDate)
        store.context.insert(reminder)
        try store.save()
        return reminder
    }

    func toggleComplete(reminder: ReminderItem) throws {
        reminder.isCompleted.toggle()
        try store.save()
    }
}

struct SwiftDataApprovalRepository: ApprovalRepository {
    let store: SwiftDataStore

    func pendingBundles() throws -> [ApprovalBundle] {
        let descriptor = FetchDescriptor<ApprovalBundle>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try store.context.fetch(descriptor).filter { $0.status == .pending }
    }

    func upsert(bundle: ApprovalBundle) throws {
        store.context.insert(bundle)
        try store.save()
    }

    func setStatus(_ status: ApprovalStatus, bundle: ApprovalBundle) throws {
        bundle.statusRaw = status.rawValue
        try store.save()
    }
}

struct SwiftDataCaptureRepository: CaptureRepository {
    let store: SwiftDataStore

    func recentCaptures(limit: Int) throws -> [CaptureItem] {
        let descriptor = FetchDescriptor<CaptureItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return Array(try store.context.fetch(descriptor).prefix(limit))
    }

    func save(capture: CaptureItem) throws {
        store.context.insert(capture)
        try store.save()
    }
}
