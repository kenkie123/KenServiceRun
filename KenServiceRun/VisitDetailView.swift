import SwiftUI

struct VisitDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let repository: any VisitRepository

    @StateObject private var viewModel: VisitDetailViewModel

    init(
        visitID: UUID,
        repository: any VisitRepository
    ) {
        self.repository = repository

        _viewModel = StateObject(
            wrappedValue: VisitDetailViewModel(
                visitID: visitID,
                repository: repository
            )
        )
    }

    var body: some View {
        Group {
            if let visit = viewModel.visit {
                List {
                    Section("Visit Details") {
                        Text(visit.siteName)
                            .font(.headline)

                        Label(
                            visit.address,
                            systemImage: "mappin.and.ellipse"
                        )

                        Label(
                            visit.scheduledDate.formatted(
                                date: .abbreviated,
                                time: .shortened
                            ),
                            systemImage: "clock"
                        )

                        if !visit.contactName.isEmpty {
                            Label(
                                visit.contactName,
                                systemImage: "person"
                            )
                        }

                        LabeledContent(
                            "Status",
                            value: visit.status.title
                        )
                    }

                    if !visit.notes.isEmpty {
                        Section("Visit Notes") {
                            Text(visit.notes)
                        }
                    }

                    Section("Tasks") {
                        ForEach(visit.tasks) { task in
                            NavigationLink {
                                TaskDetailView(
                                    visitID: visit.id,
                                    taskID: task.id,
                                    repository: repository
                                )
                            } label: {
                                HStack {
                                    Image(
                                        systemName: task.completed
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                    .foregroundStyle(
                                        task.completed
                                            ? .green
                                            : .secondary
                                    )

                                    VStack(
                                        alignment: .leading,
                                        spacing: 3
                                    ) {
                                        Text(task.title)

                                        if task.completed {
                                            Text("Completed")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text("Outstanding")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if visit.status != .completed {
                        Section {
                            Button {
                                viewModel.closeVisit()
                            } label: {
                                Text("Complete Visit")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .navigationTitle(visit.siteName)
                .navigationBarTitleDisplayMode(.inline)

            } else {
                ProgressView("Loading visit...")
            }
        }
        .onAppear {
            viewModel.loadVisit()
        }
        .onChange(of: viewModel.didCloseVisit) {
            if viewModel.didCloseVisit {
                dismiss()
            }
        }
        .alert(
            "Unable to Complete Visit",
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
