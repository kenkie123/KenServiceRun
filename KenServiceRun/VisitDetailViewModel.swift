import Foundation
import Combine

@MainActor
final class VisitDetailViewModel: ObservableObject {
    @Published var visit: Visit?
    @Published var errorMessage: String?
    @Published var didCloseVisit = false

    private let visitID: UUID
    private let repository: any VisitRepository

    init(
        visitID: UUID,
        repository: any VisitRepository
    ) {
        self.visitID = visitID
        self.repository = repository
    }

    func loadVisit() {
        do {
            visit = try repository.fetchVisit(
                id: visitID
            )

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeVisit() {
        do {
            try CloseServiceVisitUseCase(
                repository: repository
            ).execute(
                visitID: visitID
            )

            loadVisit()

            errorMessage = nil
            didCloseVisit = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
