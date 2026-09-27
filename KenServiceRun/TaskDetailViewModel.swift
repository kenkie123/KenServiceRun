import Foundation
import Combine

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published var task: VisitTaskItem?
    @Published var technicianNotes = ""
    @Published var errorMessage: String?
    @Published var didComplete = false

    private let visitID: UUID
    private let taskID: UUID
    private let repository: any VisitRepository

    init(
        visitID: UUID,
        taskID: UUID,
        repository: any VisitRepository
    ) {
        self.visitID = visitID
        self.taskID = taskID
        self.repository = repository
    }

    func loadTask() {
        do {
            let visit = try repository.fetchVisit(
                id: visitID
            )

            guard let task = visit.tasks.first(
                where: {
                    $0.id == taskID
                }
            ) else {
                errorMessage = "This task could not be found."
                return
            }

            self.task = task
            technicianNotes = task.technicianNotes
            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeTask() {
        do {
            try CompleteVisitTaskUseCase(
                repository: repository
            ).execute(
                visitID: visitID,
                taskID: taskID,
                technicianNotes: technicianNotes
            )

            loadTask()

            errorMessage = nil
            didComplete = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
