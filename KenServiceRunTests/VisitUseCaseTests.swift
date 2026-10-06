import XCTest
@testable import KenServiceRun

final class VisitUseCasesTests: XCTestCase {
    @MainActor
    
    func SchedulesValidVisit() throws {
        let repository = MockVisitRepository()

    let useCase = ScheduleServiceVisitUseCase(
        repository: repository
    )

    let visit = makeVisit()

        try useCase.execute(visit)

        XCTAssertNotNil(
            repository.visits[visit.id]
        )
}

@MainActor
    func RejectsNoSiteNameVisit() {
    let repository = MockVisitRepository()

    let useCase = ScheduleServiceVisitUseCase(
            repository: repository
    )

        var visit = makeVisit()
        visit.siteName = ""
        XCTAssertThrowsError(
            try useCase.execute(visit)
    ) { error in
            XCTAssertEqual(
                error as? ScheduleServiceVisitError,
                .missingSiteName
            )
        }
    }

@MainActor
    func RejectsBlankTaskTitle() {
        let repository = MockVisitRepository()

        let visit = makeVisit()
        repository.visits[visit.id] = visit

        let useCase = AddVisitTaskUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
        try useCase.execute(
                visitID: visit.id,
                title: "   "
            )
    ) { error in
        XCTAssertEqual(
                error as? AddVisitTaskError,
                .missingTaskTitle
            )
        }
    }

    @MainActor
    func CompleteTaskWithTechnitianNotes() throws {
        let repository = MockVisitRepository()

        let visit = makeVisit()
        repository.visits[visit.id] = visit

        let taskID = visit.tasks[0].id

        let useCase = CompleteVisitTaskUseCase(
            repository: repository
        )

        try useCase.execute(
            visitID: visit.id,
            taskID: taskID,
            technicianNotes: "Fixed printer"
        )

        let updatedVisit = try repository.fetchVisit(
            id: visit.id
        )

        XCTAssertTrue(
            updatedVisit.tasks[0].completed
        )

        XCTAssertEqual(
            updatedVisit.tasks[0].technicianNotes,
            "Fixed printer"
        )
    }

    @MainActor
    func DoesNotCloseWithIncompletSiteName() {
    let repository = MockVisitRepository()

        let visit = makeVisit()
        repository.visits[visit.id] = visit

        let useCase = CloseServiceVisitUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                visitID: visit.id
            )
        ) { error in
            XCTAssertEqual(
                error as? CloseServiceVisitError,
                .incompleteTasks
            )
        }
    }

    private func makeVisit() -> Visit {
        Visit(
            id: UUID(),
            siteName: "Test Site",
            address: "123 Test Street",
            scheduledDate: Date(),
            contactName: "John",
            status: .scheduled,
            notes: "",
            tasks: [
                VisitTaskItem(
                    id: UUID(),
                    title: "Check printer",
                    completed: false,
                    technicianNotes: ""
                )
            ]
        )
    }
}
