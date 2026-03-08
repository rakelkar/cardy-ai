import XCTest
import SwiftData
@testable import GardenGrid

@MainActor
final class GardenGridUnitTests: XCTestCase {
    var env: AppEnvironment!

    override func setUp() async throws {
        env = AppEnvironment(context: PersistenceController.makeContainer(inMemory: true).mainContext)
        try SampleDataSeeder(spaces: env.spaces, nodes: env.nodes, memories: env.memories, reminders: env.reminders, approvals: env.approvals, captures: env.captures, chats: env.chats).seedIfNeeded()
    }

    func testCreateSpaceCreatesRootNode() throws {
        let (space, root) = try env.spaces.createSpace(title: "Test Space", iconName: nil)
        XCTAssertEqual(space.rootNodeID, root.id)
    }

    func testAnalystRecursiveRequestCreatesApproval() async throws {
        let space = try XCTUnwrap(try env.spaces.fetchSpaces(includeArchived: false).first)
        let node = try XCTUnwrap(try env.nodes.fetchNode(id: XCTUnwrap(space.rootNodeID)))
        let thread = try env.chats.thread(for: node.id, type: .analyst)
        _ = try await env.ai.sendMessage(thread: thread, node: node, message: "Please run a recursive descendant summary")
        let pending = try env.approvals.pendingBundles()
        XCTAssertFalse(pending.isEmpty)
    }

    func testReminderRepositoryToggle() throws {
        let space = try XCTUnwrap(try env.spaces.fetchSpaces(includeArchived: false).first)
        let reminder = try env.reminders.create(nodeID: XCTUnwrap(space.rootNodeID), title: "Water", note: "", dueDate: .now)
        XCTAssertFalse(reminder.isCompleted)
        try env.reminders.toggleComplete(reminder: reminder)
        XCTAssertTrue(reminder.isCompleted)
    }
}
