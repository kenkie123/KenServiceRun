import Foundation

struct SharedItem: Identifiable {
    let id = UUID()
    let content: String
    let sharedDate: Date?

    var url: URL? {
        guard let url = URL(string: content) else {
            return nil
        }

        guard
            url.scheme == "http" ||
            url.scheme == "https"
        else {
            return nil
        }

        return url
    }
}

struct SharedContentStore {
    static let appGroup = "group.com.kenneth.servicerun"
    static let contentKey = "sharedContent"
    static let dateKey = "sharedContentDate"

    static func load() -> SharedItem? {
        guard
            let defaults = UserDefaults(
                suiteName: appGroup
            ),
            let content = defaults.string(
                forKey: contentKey
            ),
            !content.isEmpty
        else {
            return nil
        }

        let date = defaults.object(
            forKey: dateKey
        ) as? Date

        return SharedItem(
            content: content,
            sharedDate: date
        )
    }

    static func clear() {
        guard let defaults = UserDefaults(
            suiteName: appGroup
        ) else {
            return
        }

        defaults.removeObject(
            forKey: contentKey
        )

        defaults.removeObject(
            forKey: dateKey
        )
    }
}
