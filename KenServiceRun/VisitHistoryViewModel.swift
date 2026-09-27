import Foundation
import Combine

@MainActor
final class VisitHistoryViewModel: ObservableObject {
    @Published var completedVisits: [Visit] = []
    @Published var errorMessage: String?

    private let repository: any VisitRepository

    init(repository: any VisitRepository) {
        self.repository = repository
    }

    func loadHistory() {
        do {
            let allVisits = try repository.fetchVisits()

            completedVisits = allVisits
                .filter { $0.status == .completed }
                .sorted {
                    $0.scheduledDate > $1.scheduledDate
                }

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
