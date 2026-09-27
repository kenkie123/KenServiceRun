import SwiftUI
struct VisitHistoryView: View {
    let repository: any VisitRepository

    @StateObject private var viewModel: VisitHistoryViewModel

    init(repository: any VisitRepository) {
        self.repository = repository

        _viewModel = StateObject(
            wrappedValue: VisitHistoryViewModel(
                repository: repository
            )
        )
    }

    var body: some View {
        List {
            if viewModel.completedVisits.isEmpty {
                ContentUnavailableView(
                    "No Completed Visits",
                    systemImage: "clock.arrow.circlepath",
                    description: Text(
                        "Completed service visits will appear here."
                    )
                )

            } else {
                ForEach(viewModel.completedVisits) { visit in
                    NavigationLink {
                        VisitDetailView(
                            visitID: visit.id,
                            repository: repository
                        )
                    } label: {
                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {
                            HStack {
                                Text(visit.siteName)
                                    .font(.headline)

                                Spacer()

                                Image(
                                    systemName: "checkmark.circle.fill"
                                )
                                .foregroundStyle(.green)
                            }

                            Label(
                                visit.address,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            Label(
                                visit.scheduledDate.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                ),
                                systemImage: "calendar"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Text(
                                "\(visit.tasks.count) tasks completed"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Visit History")
        .onAppear {
            viewModel.loadHistory()
        }
        .refreshable {
            viewModel.loadHistory()
        }
        .alert(
            "Unable to Load History",
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
