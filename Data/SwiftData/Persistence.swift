import Foundation
import SwiftData

enum PersistenceController {
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            Space.self,
            Node.self,
            ChatThread.self,
            ChatMessage.self,
            MemoryEntry.self,
            ReminderItem.self,
            CaptureItem.self,
            ApprovalBundle.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
