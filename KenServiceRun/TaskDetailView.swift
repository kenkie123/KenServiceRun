import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: TaskDetailViewModel

    init(
        visitID: UUID,
        taskID: UUID,
        repository: any VisitRepository
    ) {
        _viewModel = StateObject(
            wrappedValue: TaskDetailViewModel(
                visitID: visitID,
                taskID: taskID,
                repository: repository
            )
        )
    }

    var body: some View {
        Form {
            if let task = viewModel.task {
                Section("Task") {
                    Text(task.title)
                        .font(.headline)

                    LabeledContent(
                        "Status",
                        value: task.completed
                            ? "Completed"
                            : "Outstanding"
                    )
                }

                Section("Technician Notes") {
                    TextField(
                        "Describe the work completed",
                        text: $viewModel.technicianNotes,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                    .disabled(task.completed)
                }

                if task.completed &&
                    !task.technicianNotes.isEmpty {

                    Section("Completion Notes") {
                        Text(task.technicianNotes)
                    }
                }

                if !task.completed {
                    Section {
                        Button {
                            viewModel.completeTask()
                        } label: {
                            Text("Complete Task")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            } else {
                Section {
                    ProgressView("Loading task...")
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTask()
        }
        .onChange(of: viewModel.didComplete) {
            if viewModel.didComplete {
                dismiss()
            }
        }
        .alert(
            "Unable to Complete Task",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { showing in
                    if !showing {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK") { }
        } message: {
            Text(
                viewModel.errorMessage ?? ""
            )
        }
    }
}
