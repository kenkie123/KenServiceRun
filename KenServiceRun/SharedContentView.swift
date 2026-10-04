import SwiftUI

struct SharedContentView: View {
    let item: SharedItem
    let onDone: () -> Void
    @Environment(\.dismiss)
    private var dismiss
var body: some View {
        NavigationStack {
            Form {
                Section("Shared Content") {
                    if let url = item.url {
                        Link(
                            url.absoluteString,
                            destination: url
                        )
                    } else {
                        Text(item.content)
                            .textSelection(.enabled)
                    }
                }

                if let sharedDate = item.sharedDate {
                    Section("Received") {
                        Text(
                            sharedDate.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                    }
                }
            }
            .navigationTitle(
                "Shared to ServiceRun"
            )
            .toolbar {
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Done") {
                        onDone()
                        dismiss()
                    }
                }
            }
        }
    }
}
