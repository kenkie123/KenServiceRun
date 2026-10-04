import SwiftUI
@main
struct KenServiceRunApp: App {
    var body: some Scene {
        WindowGroup {
        AppRootView()
        }
}
}
struct AppRootView: View {
    @Environment(\.scenePhase)
    private var scenePhase
    @State
    private var repository:
        CoreDataVisitRepository?
    @State
    private var errorMessage: String?
    @State
    private var sharedItem: SharedItem?
    var body: some View {
        Group {
    if let repository {
                DashboardView(
                    repository: repository
                )
            } else if let errorMessage {
                ContentUnavailableView(
                    "ServiceRun Unavailable",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(errorMessage)
                )
            } else {
                ProgressView(
                "Loading ServiceRun..."
            )
        }
        }
    .task {
            await loadRepository()
            loadSharedContent()
        }
    .onChange(of: scenePhase) {
            _, newPhase in

            if newPhase == .active {
                loadSharedContent()
            }
        }
        .sheet(
            item: $sharedItem
        ) { item in

            SharedContentView(
                item: item
        ) {
                SharedContentStore.clear()
                sharedItem = nil
        }
    }
    }

    private func loadRepository() async {
        guard repository == nil else {
            return
        }

        do {
            repository =
                try await CoreDataVisitRepository()
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }
    private func loadSharedContent() {
        sharedItem =
            SharedContentStore.load()
    }
}
