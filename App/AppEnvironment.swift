import Foundation
import SwiftData

@MainActor
@Observable
final class AppEnvironment {
    let store: SwiftDataStore
    let spaces: SpaceRepository
    let nodes: NodeRepository
    let chats: ChatRepository
    let memories: MemoryRepository
    let reminders: ReminderRepository
    let approvals: ApprovalRepository
    let captures: CaptureRepository
    let ai: AIOrchestratorService
    let reminderService: ReminderService
    let search: SearchService

    init(context: ModelContext) {
        let store = SwiftDataStore(context: context)
        self.store = store
        self.spaces = SwiftDataSpaceRepository(store: store)
        self.nodes = SwiftDataNodeRepository(store: store)
        self.chats = SwiftDataChatRepository(store: store)
        self.memories = SwiftDataMemoryRepository(store: store)
        self.reminders = SwiftDataReminderRepository(store: store)
        self.approvals = SwiftDataApprovalRepository(store: store)
        self.captures = SwiftDataCaptureRepository(store: store)
        self.ai = MockAIOrchestratorService(nodeRepository: self.nodes, reminderRepository: self.reminders, approvalRepository: self.approvals, memoryRepository: self.memories)
        self.reminderService = LocalReminderService()
        self.search = LocalSearchService(nodeRepository: self.nodes, memoryRepository: self.memories, spaceRepository: self.spaces)

        #if DEBUG
        try? SampleDataSeeder(spaces: spaces, nodes: nodes, memories: memories, reminders: reminders, approvals: approvals, captures: captures, chats: chats).seedIfNeeded()
        #endif
    }
}
