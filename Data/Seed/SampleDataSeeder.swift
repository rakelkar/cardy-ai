import Foundation

struct SampleDataSeeder {
    let spaces: SpaceRepository
    let nodes: NodeRepository
    let memories: MemoryRepository
    let reminders: ReminderRepository
    let approvals: ApprovalRepository
    let captures: CaptureRepository
    let chats: ChatRepository

    func seedIfNeeded() throws {
        guard try spaces.fetchSpaces(includeArchived: true).isEmpty else { return }
        let (garden, root) = try spaces.createSpace(title: "Garden", iconName: "leaf")

        let frontEntrance = try nodes.createChild(title: "Front Entrance", parent: root, purpose: "Keep entry looking clean")
        let roseZone = try nodes.createChild(title: "Rose Zone", parent: root, purpose: "Seasonal rose health")
        let treeArea = try nodes.createChild(title: "Tree Area", parent: root, purpose: "Monitor trees and deep watering")
        _ = treeArea
        _ = try nodes.createChild(title: "Rock Wall", parent: root, purpose: "Check irrigation and weeds")
        let indoorPlants = try nodes.createChild(title: "Indoor Plants", parent: root, purpose: "Maintain indoor growth")

        _ = try nodes.createChild(title: "Rose Bush", parent: roseZone, purpose: "Prune and inspect weekly")
        _ = try nodes.createChild(title: "Feeding Plan", parent: roseZone, purpose: "Apply fertilizer cadence")
        let diseaseWatch = try nodes.createChild(title: "Disease Watch", parent: roseZone, purpose: "Track black spot")
        _ = try nodes.createChild(title: "Companion Plants", parent: roseZone, purpose: "Protect pollinators")

        _ = try nodes.createChild(title: "Orchid 1", parent: indoorPlants, purpose: "Humidity and root checks")
        _ = try nodes.createChild(title: "Orchid 2", parent: indoorPlants, purpose: "Bloom support")
        _ = try nodes.createChild(title: "Pilea", parent: indoorPlants, purpose: "Rotate weekly")

        try memories.create(nodeID: roseZone.id, kind: .summary, title: "Weekly pass", body: "Rose zone is mostly healthy; minor mildew risk.", sourceType: .system, referenceID: nil)
        try memories.create(nodeID: frontEntrance.id, kind: .fact, title: "Mulch refreshed", body: "Applied cedar mulch near steps.", sourceType: .manual, referenceID: nil)
        try memories.create(nodeID: diseaseWatch.id, kind: .statusChange, title: "Watch status", body: "Moved to watch after rain spell.", sourceType: .system, referenceID: nil)

        _ = try reminders.create(nodeID: roseZone.id, title: "Saturday watering", note: "Deep water roses", dueDate: .now.addingTimeInterval(3600 * 24 * 2))
        _ = try reminders.create(nodeID: indoorPlants.id, title: "Rotate pilea", note: "Rotate 90 degrees", dueDate: .now.addingTimeInterval(3600 * 24))

        try captures.save(capture: CaptureItem(nodeID: roseZone.id, noteText: "Leaves look brighter", captureIntent: .storeProgressSnapshot, aiDraftSummary: "Possible nutrient recovery"))
        try captures.save(capture: CaptureItem(nodeID: indoorPlants.id, noteText: "Orchid new bud", captureIntent: .updateStatus, aiDraftSummary: "Bloom cycle starting"))

        try approvals.upsert(bundle: ApprovalBundle(nodeID: roseZone.id, requestType: .recurseReadAndSummarize, title: "Rose Zone recursive health summary", detail: "Scan all descendant tasks and produce risk summary.", scopeNodeCount: 4, descendantNodeCount: 9, willWriteMemory: true, willCreateReminders: false))
        try approvals.upsert(bundle: ApprovalBundle(nodeID: indoorPlants.id, requestType: .createReminder, title: "Create seasonal reminder set", detail: "Generate humidity reminders for orchids.", scopeNodeCount: 3, descendantNodeCount: 3, willWriteMemory: true, willCreateReminders: true))

        try nodes.archive(node: frontEntrance, reason: .seasonal)

        let manager = try chats.thread(for: roseZone.id, type: .manager)
        _ = try chats.appendMessage(threadID: manager.id, role: .assistant, content: "Rose Zone initialized. Ready for weekly planning.")

        _ = garden
    }
}
