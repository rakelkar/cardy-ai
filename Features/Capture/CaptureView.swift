import PhotosUI
import SwiftUI

struct CaptureView: View {
    let environment: AppEnvironment
    @State private var selectedItem: PhotosPickerItem?
    @State private var note = ""
    @State private var intent: CaptureIntent = .updateStatus

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button {
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo")
                }

                TextField("Quick Note", text: $note)
                    .textFieldStyle(.roundedBorder)

                Picker("Intent", selection: $intent) {
                    ForEach(CaptureIntent.allCases) { Text($0.rawValue).tag($0) }
                }

                PrimaryActionButton(title: "Save Capture") {
                    try? environment.captures.save(capture: CaptureItem(noteText: note, captureIntent: intent, aiDraftSummary: "Mock analysis: healthy progress"))
                    note = ""
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Capture")
        }
    }
}
