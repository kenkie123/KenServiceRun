import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var todaysVisits: [Visit] = []
    @Published var errorMessage: String?
private let repository: any VisitRepository
    init(repository: any VisitRepository) {
        self.repository = repository
    }

    var nextVisit: Visit? {
        todaysVisits.first
    }

    var visitCount: Int {
        todaysVisits.count
    }

    func loadVisits() {
        do {
            todaysVisits = try repository.fetchIncompleteVisits(
                on: Date()
            )

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
