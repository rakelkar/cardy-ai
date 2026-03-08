import SwiftUI

struct NodeDetailView: View {
    let environment: AppEnvironment
    let nodeID: UUID
    @State private var node: Node?
    @State private var children: [Node] = []
    @State private var selected = 0
    @State private var childTitle = ""

    var body: some View {
        Group {
            if let node {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(node.title).font(.title2.bold())
                        StatusPill(text: node.status.rawValue)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                MetricChip(title: "Children", value: "\(children.count)")
                                MetricChip(title: "Risk", value: node.riskLevel.rawValue.capitalized)
                            }
                        }
                    }.padding(.horizontal)

                    Picker("Section", selection: $selected) {
                        Text("Overview").tag(0)
                        Text("Children").tag(1)
                        Text("Chats").tag(2)
                        Text("Memory").tag(3)
                        Text("Guidance").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if selected == 1 {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
                                ForEach(children, id: \.id) { child in
                                    NavigationLink {
                                        NodeDetailView(environment: environment, nodeID: child.id)
                                    } label: {
                                        NodeCard(node: child, childCount: (try? environment.nodes.fetchChildren(parentID: child.id, in: child.spaceID, includeArchived: false).count) ?? 0)
                                    }
                                }
                            }
                            .padding()
                        }
                    } else if selected == 2 {
                        VStack {
                            NavigationLink("Manager Chat") { ChatView(environment: environment, node: node, type: .manager) }
                            NavigationLink("Analyst Chat") { ChatView(environment: environment, node: node, type: .analyst) }
                        }
                    } else if selected == 3 {
                        MemoryList(nodeID: node.id, environment: environment)
                    } else if selected == 4 {
                        Form {
                            Section("Inherited Guidance") { Text(node.inheritedGuidance.isEmpty ? "None" : node.inheritedGuidance) }
                            Section("Local Guidance") { Text(node.localGuidance.isEmpty ? "No local guidance" : node.localGuidance) }
                            Section("Effective Guidance") { Text(node.effectiveGuidanceCache.isEmpty ? "None" : node.effectiveGuidanceCache) }
                        }
                    } else {
                        Text(node.summary.isEmpty ? "No overview yet." : node.summary).padding()
                    }
                }
                .navigationTitle("Node")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Archive") {
                            try? environment.nodes.archive(node: node, reason: .dormant)
                            refresh()
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        TextField("Child title", text: $childTitle)
                            .textFieldStyle(.roundedBorder)
                        Button("Add Child") {
                            guard !childTitle.isEmpty, let node else { return }
                            _ = try? environment.nodes.createChild(title: childTitle, parent: node, purpose: "")
                            childTitle = ""
                            refresh()
                        }.buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            } else {
                ProgressView().onAppear(perform: refresh)
            }
        }
    }

    private func refresh() {
        node = try? environment.nodes.fetchNode(id: nodeID)
        if let node {
            children = (try? environment.nodes.fetchChildren(parentID: node.id, in: node.spaceID, includeArchived: false)) ?? []
        }
    }
}
