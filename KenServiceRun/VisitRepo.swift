import Foundation
import CoreData
import WidgetKit

enum VisitRepositoryError: Error, LocalizedError {
    case visitNotFound
    case taskNotFound
    case storageUnavailable
    case saveFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .visitNotFound:
            return "This visit could not be found."

        case .taskNotFound:
            return "This task could not be found."

        case .storageUnavailable:
            return "Visit storage is unavailable. Please restart the app."

        case .saveFailed:
            return "Your changes could not be saved."

        case .fetchFailed:
            return "Your visits could not be loaded."
        }
    }
}

@MainActor
protocol VisitRepository {
    func fetchVisits() throws -> [Visit]

    func fetchIncompleteVisits(
        on date: Date
    ) throws -> [Visit]

    func fetchVisit(id: UUID) throws -> Visit

    func saveVisit(_ visit: Visit) throws

    func deleteVisit(id: UUID) throws
}

@MainActor
final class CoreDataVisitRepository: VisitRepository {
    private let container: NSPersistentContainer

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) async throws {
        container = NSPersistentContainer(
            name: "ServiceRunModel"
        )

        if inMemory {
            container.persistentStoreDescriptions.first?.type =
                NSInMemoryStoreType
        }

        do {
            try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<Void, Error>) in

                container.loadPersistentStores { _, error in
                    if let error {
                        continuation.resume(
                            throwing: error
                        )
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            throw VisitRepositoryError.storageUnavailable
        }

        updateWidget()
    }

    func fetchVisits() throws -> [Visit] {
        try fetchVisits(
            matching: nil
        )
    }

    func fetchIncompleteVisits(
        on date: Date
    ) throws -> [Visit] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(
            for: date
        )

        guard let end = calendar.date(
            byAdding: .day,
            value: 1,
            to: start
        ) else {
            throw VisitRepositoryError.fetchFailed
        }

        let predicate = NSPredicate(
            format: """
            scheduledDate >= %@ AND scheduledDate < %@ AND status != %@
            """,
            start as NSDate,
            end as NSDate,
            VisitStatus.completed.rawValue
        )

        return try fetchVisits(
            matching: predicate
        )
    }

    func fetchVisit(
        id: UUID
    ) throws -> Visit {
        guard let record = try findRecord(
            id: id
        ) else {
            throw VisitRepositoryError.visitNotFound
        }

        return try makeVisit(
            from: record
        )
    }

    func saveVisit(
        _ visit: Visit
    ) throws {
        let existingRecord = try findRecord(
            id: visit.id
        )

        let record =
            existingRecord ??
            ServiceVisit(
                context: context
            )

        record.id = visit.id
        record.siteName = visit.siteName
        record.address = visit.address
        record.scheduledDate = visit.scheduledDate
        record.contactName = visit.contactName
        record.status = visit.status.rawValue
        record.notes = visit.notes

        let previousTasks =
            record.tasks as? Set<VisitTask> ?? []

        for task in previousTasks {
            context.delete(task)
        }

        for item in visit.tasks {
            let task = VisitTask(
                context: context
            )

            task.id = item.id
            task.title = item.title
            task.completed = item.completed
            task.technicianNotes =
                item.technicianNotes

            task.visit = record
        }

        try saveChanges()

        updateWidget()
    }

    func deleteVisit(
        id: UUID
    ) throws {
        guard let record = try findRecord(
            id: id
        ) else {
            throw VisitRepositoryError.visitNotFound
        }

        context.delete(record)

        try saveChanges()

        updateWidget()
    }

    private func fetchVisits(
        matching predicate: NSPredicate?
    ) throws -> [Visit] {
        let request =
            NSFetchRequest<ServiceVisit>(
                entityName: "ServiceVisit"
            )

        request.predicate = predicate

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "scheduledDate",
                ascending: true
            ),
            NSSortDescriptor(
                key: "siteName",
                ascending: true
            )
        ]

        do {
            let records = try context.fetch(
                request
            )

            return try records.map {
                try makeVisit(
                    from: $0
                )
            }

        } catch {
            throw VisitRepositoryError.fetchFailed
        }
    }

    private func findRecord(
        id: UUID
    ) throws -> ServiceVisit? {
        let request =
            NSFetchRequest<ServiceVisit>(
                entityName: "ServiceVisit"
            )

        request.predicate = NSPredicate(
            format: "id == %@",
            id as NSUUID
        )

        request.fetchLimit = 1

        do {
            return try context.fetch(
                request
            ).first

        } catch {
            throw VisitRepositoryError.fetchFailed
        }
    }

    private func makeVisit(
        from record: ServiceVisit
    ) throws -> Visit {
        guard
            let id = record.id,
            let siteName = record.siteName,
            let address = record.address,
            let scheduledDate =
                record.scheduledDate,
            let statusValue =
                record.status,
            let status =
                VisitStatus(
                    rawValue: statusValue
                )
        else {
            throw VisitRepositoryError.fetchFailed
        }

        let storedTasks =
            record.tasks as? Set<VisitTask> ?? []

        let tasks = try storedTasks
            .map {
                task -> VisitTaskItem in

                guard
                    let taskID = task.id,
                    let title = task.title
                else {
                    throw VisitRepositoryError.fetchFailed
                }

                return VisitTaskItem(
                    id: taskID,
                    title: title,
                    completed: task.completed,
                    technicianNotes:
                        task.technicianNotes ?? ""
                )
            }
            .sorted {
                if $0.title == $1.title {
                    return $0.id.uuidString <
                        $1.id.uuidString
                }

                return $0.title < $1.title
            }

        return Visit(
            id: id,
            siteName: siteName,
            address: address,
            scheduledDate: scheduledDate,
            contactName:
                record.contactName ?? "",
            status: status,
            notes:
                record.notes ?? "",
            tasks: tasks
        )
    }

    private func saveChanges() throws {
        do {
            try context.save()

        } catch {
            context.rollback()

            throw VisitRepositoryError.saveFailed
        }
    }

    private func updateWidget() {
        do {
            let visits =
                try fetchIncompleteVisits(
                    on: Date()
                )

            let nextVisit =
                visits.first

            let data = SharedWidgetData(
                siteName:
                    nextVisit?.siteName,
                scheduledDate:
                    nextVisit?.scheduledDate,
                tasksRemaining:
                    nextVisit?
                        .outstandingTaskCount ?? 0,
                visitCount:
                    visits.count
            )

            WidgetDataStore.save(
                data
            )

            WidgetCenter.shared
                .reloadAllTimelines()

        } catch {
            return
        }
    }
}
