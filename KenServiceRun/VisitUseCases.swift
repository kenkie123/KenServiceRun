import Foundation
enum ScheduleServiceVisitError: Error, LocalizedError, Equatable {
    case missingSiteName
    case missingAddress
    case noTasks
    case missingTaskTitle

    var errorDescription: String? {
        switch self {
        case .missingSiteName:
            return "Enter a site name."

        case .missingAddress:
            return "Enter a site address."

        case .noTasks:
            return "Add at least one task before scheduling the visit."

        case .missingTaskTitle:
            return "Each visit task must have a title."
        }
    }
}

@MainActor
struct ScheduleServiceVisitUseCase {
    let repository: any VisitRepository

    func execute(_ visit: Visit) throws {
        var updatedVisit = visit

        updatedVisit.siteName = visit.siteName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        updatedVisit.address = visit.address.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        updatedVisit.contactName = visit.contactName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        updatedVisit.notes = visit.notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !updatedVisit.siteName.isEmpty else {
            throw ScheduleServiceVisitError.missingSiteName
        }

        guard !updatedVisit.address.isEmpty else {
            throw ScheduleServiceVisitError.missingAddress
        }

        guard !updatedVisit.tasks.isEmpty else {
            throw ScheduleServiceVisitError.noTasks
        }

        for index in updatedVisit.tasks.indices {
            updatedVisit.tasks[index].title =
                updatedVisit.tasks[index].title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            guard !updatedVisit.tasks[index].title.isEmpty else {
                throw ScheduleServiceVisitError.missingTaskTitle
            }
        }

        try repository.saveVisit(updatedVisit)
    }
}


// MARK: - Add Visit Task

enum AddVisitTaskError: Error, LocalizedError, Equatable {
    case missingTaskTitle
    case visitAlreadyCompleted

    var errorDescription: String? {
        switch self {
        case .missingTaskTitle:
            return "Enter a task title."

        case .visitAlreadyCompleted:
            return "Tasks cannot be added to a completed visit."
        }
    }
}

@MainActor
struct AddVisitTaskUseCase {
    let repository: any VisitRepository

    func execute(
        visitID: UUID,
        title: String
    ) throws {
        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedTitle.isEmpty else {
            throw AddVisitTaskError.missingTaskTitle
        }

        var visit = try repository.fetchVisit(id: visitID)

        guard visit.status != .completed else {
            throw AddVisitTaskError.visitAlreadyCompleted
        }

        visit.tasks.append(
            VisitTaskItem(
                title: cleanedTitle
            )
        )

        try repository.saveVisit(visit)
    }
}


// MARK: - Complete Visit Task

enum CompleteVisitTaskError: Error, LocalizedError, Equatable {
    case visitAlreadyCompleted
    case taskNotFound
    case taskAlreadyCompleted
    case missingTechnicianNotes

    var errorDescription: String? {
        switch self {
        case .visitAlreadyCompleted:
            return "This visit has already been completed."

        case .taskNotFound:
            return "This task could not be found."

        case .taskAlreadyCompleted:
            return "This task has already been completed."

        case .missingTechnicianNotes:
            return "Enter technician notes before completing this task."
        }
    }
}

@MainActor
struct CompleteVisitTaskUseCase {
    let repository: any VisitRepository

    func execute(
        visitID: UUID,
        taskID: UUID,
        technicianNotes: String
    ) throws {
        var visit = try repository.fetchVisit(id: visitID)

        guard visit.status != .completed else {
            throw CompleteVisitTaskError.visitAlreadyCompleted
        }

        guard let index = visit.tasks.firstIndex(
            where: { $0.id == taskID }
        ) else {
            throw CompleteVisitTaskError.taskNotFound
        }

        guard !visit.tasks[index].completed else {
            throw CompleteVisitTaskError.taskAlreadyCompleted
        }

        let cleanedNotes = technicianNotes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedNotes.isEmpty else {
            throw CompleteVisitTaskError.missingTechnicianNotes
        }

        visit.tasks[index].completed = true
        visit.tasks[index].technicianNotes = cleanedNotes

        if visit.status == .scheduled {
            visit.status = .inProgress
        }

        try repository.saveVisit(visit)
    }
}
enum CloseServiceVisitError: Error, LocalizedError, Equatable {
    case visitAlreadyCompleted
    case noTasks
    case incompleteTasks

    var errorDescription: String? {
        switch self {
        case .visitAlreadyCompleted:
            return "This visit has already been completed."

        case .noTasks:
            return "A visit must contain at least one task before it can be completed."

        case .incompleteTasks:
            return "Complete all outstanding tasks before closing this visit."
        }
    }
}

@MainActor
struct CloseServiceVisitUseCase {
    let repository: any VisitRepository

    func execute(
        visitID: UUID
    ) throws {
        var visit = try repository.fetchVisit(id: visitID)

        guard visit.status != .completed else {
            throw CloseServiceVisitError.visitAlreadyCompleted
        }

        guard !visit.tasks.isEmpty else {
            throw CloseServiceVisitError.noTasks
        }

        guard visit.tasks.allSatisfy({ $0.completed }) else {
            throw CloseServiceVisitError.incompleteTasks
        }

        visit.status = .completed

        try repository.saveVisit(visit)
    }
}
