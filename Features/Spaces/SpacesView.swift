import SwiftUI

struct SpacesView: View {
    let environment: AppEnvironment
    @State private var spaces: [Space] = []
    @State private var newTitle = ""

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(spaces, id: \.id) { space in
                        NavigationLink {
                            if let rootID = space.rootNodeID {
                                NodeDetailView(environment: environment, nodeID: rootID)
                            }
                        } label: {
                            SpaceCard(space: space)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Spaces")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New") {
                        if !newTitle.isEmpty {
                            _ = try? environment.spaces.createSpace(title: newTitle, iconName: "leaf")
                            load()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Create a space", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    PrimaryActionButton(title: "Add") {
                        if !newTitle.isEmpty {
                            _ = try? environment.spaces.createSpace(title: newTitle, iconName: "leaf")
                            newTitle = ""
                            load()
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        spaces = (try? environment.spaces.fetchSpaces(includeArchived: false)) ?? []
    }
}
