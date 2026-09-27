import SwiftUI
import Foundation

@main
struct KenServiceRunApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

private struct AppRootView: View {
    @State private var repository: CoreDataVisitRepository?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let repository {
                DashboardView(repository: repository)

            } else if let errorMessage {
                ContentUnavailableView(
                    "ServiceRun Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )

            } else {
                ProgressView("Loading")
            }
        }
        .task {
            guard repository == nil else {
                return
            }

            do {
                repository = try await CoreDataVisitRepository()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
