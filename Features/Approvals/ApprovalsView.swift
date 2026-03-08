import SwiftUI

struct ApprovalsView: View {
    let environment: AppEnvironment
    @State private var bundles: [ApprovalBundle] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(bundles, id: \.id) { bundle in
                    VStack(alignment: .leading, spacing: 8) {
                        ApprovalCard(bundle: bundle)
                        HStack {
                            Button("Approve Once") { update(bundle, .approvedOnce) }
                            Button("Approve for Chat") { update(bundle, .approvedForChat) }
                            Button("Deny", role: .destructive) { update(bundle, .denied) }
                        }
                    }
                }
            }
            .navigationTitle("Approvals")
            .onAppear(perform: load)
        }
    }

    private func update(_ bundle: ApprovalBundle, _ status: ApprovalStatus) {
        try? environment.approvals.setStatus(status, bundle: bundle)
        load()
    }

    private func load() {
        bundles = (try? environment.approvals.pendingBundles()) ?? []
    }
}
