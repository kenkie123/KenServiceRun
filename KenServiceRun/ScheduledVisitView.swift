import SwiftUI
import Foundation
import Combine

@MainActor
final class ScheduleVisitViewModel: ObservableObject {
    @Published var siteName = ""
    @Published var address = ""
    @Published var contactName = ""
    @Published var scheduledDate = Date()
    @Published var notes = ""

    @Published var taskTitle = ""
    @Published var tasks: [VisitTaskItem] = []

    @Published var errorMessage: String?
    @Published var didSave = false

    private let repository: any VisitRepository

    init(repository: any VisitRepository) {
        self.repository = repository
    }

    func addTask() {
        let cleanedTitle = taskTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else {
            errorMessage = "Enter a task title."
            return
        }

        tasks.append(
            VisitTaskItem(
                title: cleanedTitle
            )
        )

        taskTitle = ""
        errorMessage = nil
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }

    func saveVisit() {
        let visit = Visit(
            siteName: siteName,
            address: address,
            scheduledDate: scheduledDate,
            contactName: contactName,
            status: .scheduled,
            notes: notes,
            tasks: tasks
        )

        do {
            try ScheduleServiceVisitUseCase(
                repository: repository
            ).execute(visit)

            errorMessage = nil
            didSave = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


struct ScheduleVisitView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ScheduleVisitViewModel

    init(repository: any VisitRepository) {
        _viewModel = StateObject(
            wrappedValue: ScheduleVisitViewModel(
                repository: repository
            )
        )
    }

    var body: some View {
        Form {
            Section("Site Details") {
                TextField(
                    "Site name",
                    text: $viewModel.siteName
                )

                TextField(
                    "Address",
                    text: $viewModel.address
                )

                TextField(
                    "Contact name",
                    text: $viewModel.contactName
                )
            }

            Section("Schedule") {
                DatePicker(
                    "Visit date and time",
                    selection: $viewModel.scheduledDate
                )
            }

            Section("Visit Notes") {
                TextField(
                    "Notes",
                    text: $viewModel.notes,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            Section("Visit Tasks") {
                HStack {
                    TextField(
                        "Task title",
                        text: $viewModel.taskTitle
                    )

                    Button("Add") {
                        viewModel.addTask()
                    }
                }

                ForEach(viewModel.tasks) { task in
                    Label(
                        task.title,
                        systemImage: "circle"
                    )
                }
                .onDelete(
                    perform: viewModel.deleteTask
                )
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Label(
                        errorMessage,
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    viewModel.saveVisit()
                } label: {
                    Text("Schedule Visit")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Schedule Visit")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.didSave) {
            if viewModel.didSave {
                dismiss()
            }
        }
    }
}
