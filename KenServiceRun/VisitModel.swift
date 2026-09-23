import Foundation
enum VisitStatus: String, CaseIterable, Identifiable {
    case scheduled
      case inProgress
    case completed
    var id: String { rawValue }
    var title: String {
        switch self {
        case .scheduled:
            return "Scheduled"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        }
    }
}
struct Visit: Identifiable, Equatable {
    let id: UUID
    var siteName: String
    var address: String
    var scheduledDate: Date
    var contactName: String
    var status: VisitStatus
    var notes: String
    var tasks: [VisitTaskItem]

    var outstandingTaskCount: Int {
        tasks.filter { !$0.completed }.count
    }

    init(
        id: UUID = UUID(),
        siteName: String,
        address: String,
        scheduledDate: Date,
        contactName: String = "",
        status: VisitStatus = .scheduled,
        notes: String = "",
        tasks: [VisitTaskItem] = []
    ) {
        self.id = id
        self.siteName = siteName
        self.address = address
        self.scheduledDate = scheduledDate
        self.contactName = contactName
        self.status = status
        self.notes = notes
        self.tasks = tasks
    }
}

struct VisitTaskItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var completed: Bool = false
    var technicianNotes: String = ""
}
