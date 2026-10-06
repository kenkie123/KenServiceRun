import SwiftUI

struct DashboardView: View {
    let repository: any VisitRepository
    @StateObject private var viewModel: DashboardViewModel
    init(repository: any VisitRepository) {
        self.repository = repository
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(
                repository: repository
        )
    )
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {
                        Text("Today's Run")
                            .font(.headline)

                Text(
                        "\(viewModel.visitCount) " +
                            (viewModel.visitCount == 1 ? "visit" : "visits")
                        )
                        .foregroundStyle(.secondary)
                }
                    .padding(.vertical, 4)
                }

                if let nextVisit = viewModel.nextVisit {
                    Section("Next Visit") {
                        NavigationLink {
                            VisitDetailView(
                                visitID: nextVisit.id,
                                repository: repository
                    )
                        } label: {
                            VStack(
                                alignment: .leading,
                                spacing: 8
                            ) {
                                Text(nextVisit.siteName)
                                    .font(.headline)

                                Label(
                                    nextVisit.scheduledDate.formatted(
                                        date: .omitted,
                                        time: .shortened
                                    ),
                                    systemImage: "clock"
                                )

                                Label(
                                    nextVisit.address,
                                    systemImage: "mappin.and.ellipse"
                                )

                                Text(
                                    "\(nextVisit.outstandingTaskCount) tasks remaining"
                                )
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Today's Visits") {
                    if viewModel.todaysVisits.isEmpty {
                        ContentUnavailableView(
                            "No Visits Today",
                            systemImage: "calendar.badge.checkmark",
                            description: Text(
                                "Schedule a service visit to get started."
                            )
                        )
                    } else {
                        ForEach(viewModel.todaysVisits) { visit in
                            NavigationLink {
                                VisitDetailView(
                                    visitID: visit.id,
                                    repository: repository
                                )
                            } label: {
                                VStack(
                                    alignment: .leading,
                                    spacing: 5
                                ) {
                                    HStack {
                                        Text(visit.siteName)
                                            .font(.headline)

                                        Spacer()

                                        Text(
                                            visit.scheduledDate.formatted(
                                                date: .omitted,
                                                time: .shortened
                                            )
                                        )
                                        .foregroundStyle(.secondary)
                                    }

                                    Label(
                                        visit.address,
                                        systemImage: "mappin.and.ellipse"
                                    )
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                    HStack {
                                        Text(
                                            "\(visit.outstandingTaskCount) tasks remaining"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                        Spacer()

                                        Text(visit.status.title)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 3)
                    }
                        }
            }
        }
            }
            .navigationTitle("ServiceRun")
            .toolbar {
                ToolbarItemGroup(
                    placement: .topBarTrailing
                ) {
                    NavigationLink {
                        VisitHistoryView(
                            repository: repository
                        )
                    } label: {
                        Image(
                            systemName: "clock.arrow.circlepath"
                        )
                    }

                    NavigationLink {
                        ScheduleVisitView(
                            repository: repository
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.loadVisits()
            }
            .refreshable {
                viewModel.loadVisits()
            }
            .alert(
                "Unable to Load Visits",
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
}
