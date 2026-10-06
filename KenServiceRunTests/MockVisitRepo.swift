import Foundation
@testable import KenServiceRun

@MainActor
final class MockVisitRepository: VisitRepository {
    var visits: [UUID: Visit] = [:]

    func fetchVisits() throws -> [Visit] {
        Array(visits.values)
    }

    func fetchIncompleteVisits(on date: Date) throws -> [Visit] {
        Array(visits.values)
    }

    func fetchVisit(id: UUID) throws -> Visit {
        guard let visit = visits[id] else {
            throw VisitRepositoryError.visitNotFound
        }

        return visit
    }

    func saveVisit(_ visit: Visit) throws {
        visits[visit.id] = visit
    }

    func deleteVisit(id: UUID) throws {
        visits.removeValue(forKey: id)
    }
}
