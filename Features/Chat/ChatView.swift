import SwiftUI

struct ChatView: View {
    let environment: AppEnvironment
    let node: Node
    let type: ChatType
    @State private var thread: ChatThread?
    @State private var messages: [ChatMessage] = []
    @State private var input = ""

    var body: some View {
        VStack {
            if let thread {
                Text("\(node.title) • \(type.rawValue.capitalized)")
                    .font(.headline)
                List(messages, id: \.id) { message in
                    HStack {
                        if message.role == .assistant { Spacer() }
                        Text(message.content)
                            .padding(8)
                            .background(message.role == .assistant ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        if message.role == .user { Spacer() }
                    }
                }
                HStack {
                    TextField("Message", text: $input)
                    Button("Send") { send(on: thread) }
                }
                .padding()
            } else {
                ProgressView().task { loadThread() }
            }
        }
        .navigationTitle("Chat")
    }

    private func loadThread() {
        thread = try? environment.chats.thread(for: node.id, type: type)
        messages = (try? environment.chats.messages(threadID: thread?.id ?? UUID())) ?? []
    }

    private func send(on thread: ChatThread) {
        let text = input
        guard !text.isEmpty else { return }
        _ = try? environment.chats.appendMessage(threadID: thread.id, role: .user, content: text)
        Task {
            let response = try? await environment.ai.sendMessage(thread: thread, node: node, message: text)
            _ = try? environment.chats.appendMessage(threadID: thread.id, role: .assistant, content: response?.content ?? "")
            messages = (try? environment.chats.messages(threadID: thread.id)) ?? []
        }
        input = ""
        messages = (try? environment.chats.messages(threadID: thread.id)) ?? []
    }
}
