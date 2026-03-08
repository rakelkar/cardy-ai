import SwiftUI

struct MemoryView: View {
    let environment: AppEnvironment
    @State private var query = ""
    @State private var memories: [MemoryEntry] = []
    @State private var result: SearchResults = .init(nodes: [], memories: [])

    var body: some View {
        NavigationStack {
            List {
                Section("Search") {
                    TextField("Search nodes and memory", text: $query)
                        .onSubmit {
                            result = (try? environment.search.search(query: query)) ?? .init(nodes: [], memories: [])
                        }
                    ForEach(result.nodes, id: \.id) { Text($0.title) }
                }
                Section("Recent Memory") {
                    ForEach(memories, id: \.id) { MemoryRow(entry: $0) }
                }
            }
            .navigationTitle("Memory")
            .onAppear { memories = (try? environment.memories.timeline(nodeID: nil)) ?? [] }
        }
    }
}

struct MemoryList: View {
    let nodeID: UUID
    let environment: AppEnvironment
    @State private var entries: [MemoryEntry] = []

    var body: some View {
        List(entries, id: \.id) { MemoryRow(entry: $0) }
            .onAppear { entries = (try? environment.memories.timeline(nodeID: nodeID)) ?? [] }
    }
}
