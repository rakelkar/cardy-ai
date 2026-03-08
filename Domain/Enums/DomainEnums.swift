import Foundation

public enum NodeStatus: String, Codable, CaseIterable, Identifiable {
    case active, healthy, watch, blocked, dormant, complete, seasonal, archived
    public var id: String { rawValue }
}

public enum ChatType: String, Codable, CaseIterable, Identifiable {
    case manager, analyst
    public var id: String { rawValue }
}

public enum MessageRole: String, Codable, CaseIterable {
    case user, assistant, system, tool
}

public enum MemoryKind: String, Codable, CaseIterable, Identifiable {
    case fact, summary, statusChange, reminderNote, captureNote
    public var id: String { rawValue }
}

public enum MemorySourceType: String, Codable, CaseIterable {
    case manual, chat, capture, reminder, system
}

public enum CaptureIntent: String, Codable, CaseIterable, Identifiable {
    case updateStatus, askWhatChanged, createTask, storeProgressSnapshot
    public var id: String { rawValue }
}

public enum ApprovalRequestType: String, Codable, CaseIterable {
    case recurseRead, recurseReadAndSummarize, writeMemory, createReminder, archiveChildren, bulkStatusUpdate
}

public enum ApprovalStatus: String, Codable, CaseIterable, Identifiable {
    case pending, approvedOnce, approvedForChat, denied, expired
    public var id: String { rawValue }
}

public enum RiskLevel: String, Codable, CaseIterable, Identifiable {
    case low, medium, high
    public var id: String { rawValue }
}

public enum ArchiveReason: String, Codable, CaseIterable, Identifiable {
    case seasonal, completed, dormant, noLongerRelevant, superseded
    public var id: String { rawValue }
}

public enum Cadence: String, Codable, CaseIterable, Identifiable {
    case daily, weekly, biWeekly, monthly, seasonal
    public var id: String { rawValue }
}
