import SwiftUI

struct HomeView: View {
    let environment: AppEnvironment
    @State private var due: [ReminderItem] = []
    @State private var approvals: [ApprovalBundle] = []
    @State private var captures: [CaptureItem] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Due Today")
                    ScrollView(.horizontal) {
                        HStack { ForEach(due, id: \.id) { MetricChip(title: $0.title, value: $0.dueDate.formatted(date: .abbreviated, time: .shortened)) } }
                    }
                    SectionHeader(title: "Needs Approval")
                    ForEach(approvals, id: \.id) { ApprovalCard(bundle: $0) }
                    SectionHeader(title: "Recent Captures")
                    ForEach(captures, id: \.id) { Text($0.noteText ?? "Photo capture") }
                }
                .padding()
            }
            .navigationTitle("Home")
            .onAppear(perform: load)
        }
    }

    private func load() {
        due = ((try? environment.reminders.reminders(nodeID: nil)) ?? []).filter { Calendar.current.isDateInToday($0.dueDate) }
        approvals = (try? environment.approvals.pendingBundles()) ?? []
        captures = (try? environment.captures.recentCaptures(limit: 5)) ?? []
    }
}
