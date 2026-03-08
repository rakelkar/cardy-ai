import SwiftUI

struct StatusPill: View {
    let text: String
    var body: some View {
        Text(text.capitalized)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.thinMaterial)
            .clipShape(Capsule())
    }
}

struct MetricChip: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct NodeCard: View {
    let node: Node
    let childCount: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node.title).font(.headline).lineLimit(2)
            StatusPill(text: node.status.rawValue)
            Text("\(childCount) children").font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(LinearGradient(colors: [.green.opacity(0.2), .gray.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}

struct SpaceCard: View {
    let space: Space
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: space.iconName ?? "square.grid.2x2")
                .font(.title2)
            Text(space.title).font(.headline)
            Text(space.isArchived ? "Archived" : "Active").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}

struct ApprovalCard: View {
    let bundle: ApprovalBundle
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(bundle.title).font(.headline)
            Text(bundle.detail).font(.subheadline).foregroundStyle(.secondary)
            HStack {
                MetricChip(title: "Scope", value: "\(bundle.scopeNodeCount)")
                MetricChip(title: "Desc", value: "\(bundle.descendantNodeCount)")
            }
        }
        .padding()
        .background(.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
    }
}

struct MemoryRow: View {
    let entry: MemoryEntry
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(entry.title).font(.headline)
                Text(entry.body).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text(entry.kind.rawValue).font(.caption)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "leaf")
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack { Text(title).font(.title3.bold()); Spacer() }
            .padding(.vertical, 4)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .tint(.gardenAccent)
    }
}
