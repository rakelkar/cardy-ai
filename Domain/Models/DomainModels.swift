import Foundation
import SwiftData

@Model
final class Space {
    @Attribute(.unique) var id: UUID
    var title: String
    var iconName: String?
    var colorToken: String?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var rootNodeID: UUID?

    init(id: UUID = UUID(), title: String, iconName: String? = nil, colorToken: String? = nil, createdAt: Date = .now, updatedAt: Date = .now, isArchived: Bool = false, rootNodeID: UUID? = nil) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.colorToken = colorToken
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.rootNodeID = rootNodeID
    }
}

@Model
final class Node {
    @Attribute(.unique) var id: UUID
    var title: String
    var summary: String
    var purpose: String
    var statusRaw: String
    var cadenceRaw: String?
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var archivedReasonRaw: String?
    var parentNodeID: UUID?
    var spaceID: UUID
    var inheritedGuidance: String
    var localGuidance: String
    var effectiveGuidanceCache: String
    var sortOrder: Int
    var coverImageData: Data?
    var lastPhotoAt: Date?
    var riskLevelRaw: String
    var healthNote: String?

    init(id: UUID = UUID(), title: String, summary: String = "", purpose: String = "", status: NodeStatus = .active, cadence: Cadence? = nil, createdAt: Date = .now, updatedAt: Date = .now, isArchived: Bool = false, archivedReason: ArchiveReason? = nil, parentNodeID: UUID? = nil, spaceID: UUID, inheritedGuidance: String = "", localGuidance: String = "", effectiveGuidanceCache: String = "", sortOrder: Int = 0, coverImageData: Data? = nil, lastPhotoAt: Date? = nil, riskLevel: RiskLevel = .low, healthNote: String? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.purpose = purpose
        self.statusRaw = status.rawValue
        self.cadenceRaw = cadence?.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.archivedReasonRaw = archivedReason?.rawValue
        self.parentNodeID = parentNodeID
        self.spaceID = spaceID
        self.inheritedGuidance = inheritedGuidance
        self.localGuidance = localGuidance
        self.effectiveGuidanceCache = effectiveGuidanceCache
        self.sortOrder = sortOrder
        self.coverImageData = coverImageData
        self.lastPhotoAt = lastPhotoAt
        self.riskLevelRaw = riskLevel.rawValue
        self.healthNote = healthNote
    }

    var status: NodeStatus { NodeStatus(rawValue: statusRaw) ?? .active }
    var cadence: Cadence? { cadenceRaw.flatMap { Cadence(rawValue: $0) } }
    var archivedReason: ArchiveReason? { archivedReasonRaw.flatMap { ArchiveReason(rawValue: $0) } }
    var riskLevel: RiskLevel { RiskLevel(rawValue: riskLevelRaw) ?? .low }
}

@Model
final class ChatThread {
    @Attribute(.unique) var id: UUID
    var nodeID: UUID
    var typeRaw: String
    var title: String
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), nodeID: UUID, type: ChatType, title: String, createdAt: Date = .now, updatedAt: Date = .now) {
        self.id = id
        self.nodeID = nodeID
        self.typeRaw = type.rawValue
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: ChatType { ChatType(rawValue: typeRaw) ?? .manager }
}

@Model
final class ChatMessage {
    @Attribute(.unique) var id: UUID
    var threadID: UUID
    var roleRaw: String
    var content: String
    var createdAt: Date

    init(id: UUID = UUID(), threadID: UUID, role: MessageRole, content: String, createdAt: Date = .now) {
        self.id = id
        self.threadID = threadID
        self.roleRaw = role.rawValue
        self.content = content
        self.createdAt = createdAt
    }

    var role: MessageRole { MessageRole(rawValue: roleRaw) ?? .assistant }
}

@Model
final class MemoryEntry {
    @Attribute(.unique) var id: UUID
    var nodeID: UUID
    var kindRaw: String
    var title: String
    var body: String
    var sourceTypeRaw: String
    var sourceReferenceID: UUID?
    var createdAt: Date
    var supersedesMemoryID: UUID?
    var version: Int

    init(id: UUID = UUID(), nodeID: UUID, kind: MemoryKind, title: String, body: String, sourceType: MemorySourceType, sourceReferenceID: UUID? = nil, createdAt: Date = .now, supersedesMemoryID: UUID? = nil, version: Int = 1) {
        self.id = id
        self.nodeID = nodeID
        self.kindRaw = kind.rawValue
        self.title = title
        self.body = body
        self.sourceTypeRaw = sourceType.rawValue
        self.sourceReferenceID = sourceReferenceID
        self.createdAt = createdAt
        self.supersedesMemoryID = supersedesMemoryID
        self.version = version
    }

    var kind: MemoryKind { MemoryKind(rawValue: kindRaw) ?? .fact }
}

@Model
final class ReminderItem {
    @Attribute(.unique) var id: UUID
    var nodeID: UUID
    var title: String
    var note: String
    var dueDate: Date
    var isCompleted: Bool
    var createdAt: Date
    var notificationIdentifier: String?

    init(id: UUID = UUID(), nodeID: UUID, title: String, note: String = "", dueDate: Date, isCompleted: Bool = false, createdAt: Date = .now, notificationIdentifier: String? = nil) {
        self.id = id
        self.nodeID = nodeID
        self.title = title
        self.note = note
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.notificationIdentifier = notificationIdentifier
    }
}

@Model
final class CaptureItem {
    @Attribute(.unique) var id: UUID
    var nodeID: UUID?
    var imageData: Data?
    var noteText: String?
    var createdAt: Date
    var captureIntentRaw: String
    var aiDraftSummary: String?
    var confirmedSummary: String?

    init(id: UUID = UUID(), nodeID: UUID? = nil, imageData: Data? = nil, noteText: String? = nil, createdAt: Date = .now, captureIntent: CaptureIntent, aiDraftSummary: String? = nil, confirmedSummary: String? = nil) {
        self.id = id
        self.nodeID = nodeID
        self.imageData = imageData
        self.noteText = noteText
        self.createdAt = createdAt
        self.captureIntentRaw = captureIntent.rawValue
        self.aiDraftSummary = aiDraftSummary
        self.confirmedSummary = confirmedSummary
    }

    var captureIntent: CaptureIntent { CaptureIntent(rawValue: captureIntentRaw) ?? .updateStatus }
}

@Model
final class ApprovalBundle {
    @Attribute(.unique) var id: UUID
    var nodeID: UUID
    var threadID: UUID?
    var requestTypeRaw: String
    var title: String
    var detail: String
    var scopeNodeCount: Int
    var descendantNodeCount: Int
    var willWriteMemory: Bool
    var willCreateReminders: Bool
    var statusRaw: String
    var createdAt: Date
    var expiresAt: Date?

    init(id: UUID = UUID(), nodeID: UUID, threadID: UUID? = nil, requestType: ApprovalRequestType, title: String, detail: String, scopeNodeCount: Int, descendantNodeCount: Int, willWriteMemory: Bool, willCreateReminders: Bool, status: ApprovalStatus = .pending, createdAt: Date = .now, expiresAt: Date? = nil) {
        self.id = id
        self.nodeID = nodeID
        self.threadID = threadID
        self.requestTypeRaw = requestType.rawValue
        self.title = title
        self.detail = detail
        self.scopeNodeCount = scopeNodeCount
        self.descendantNodeCount = descendantNodeCount
        self.willWriteMemory = willWriteMemory
        self.willCreateReminders = willCreateReminders
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }

    var status: ApprovalStatus { ApprovalStatus(rawValue: statusRaw) ?? .pending }
}
