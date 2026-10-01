import Foundation

struct SharedWidgetData: Codable {
    let siteName: String?
    let scheduledDate: Date?
    let tasksRemaining: Int
    let visitCount: Int
}

struct WidgetDataStore {
    static let appGroup = "group.com.kenneth.servicerun"
    static let key = "widgetData"

    static func save(_ data: SharedWidgetData) {
        guard let defaults = UserDefaults(
            suiteName: appGroup
        ) else {
            return
        }

        guard let encoded = try? JSONEncoder().encode(data) else {
            return
        }

        defaults.set(encoded, forKey: key)
    }

    static func load() -> SharedWidgetData {
        guard
            let defaults = UserDefaults(
                suiteName: appGroup
            ),
            let data = defaults.data(forKey: key),
            let decoded = try? JSONDecoder().decode(
                SharedWidgetData.self,
                from: data
            )
        else {
            return SharedWidgetData(
                siteName: nil,
                scheduledDate: nil,
                tasksRemaining: 0,
                visitCount: 0
            )
        }

        return decoded
    }
}
