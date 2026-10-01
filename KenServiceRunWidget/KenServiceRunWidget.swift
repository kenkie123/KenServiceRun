import WidgetKit
import SwiftUI

struct ServiceRunEntry: TimelineEntry {
    let date: Date
    let data: SharedWidgetData
}

struct ServiceRunProvider: TimelineProvider {
    func placeholder(
        in context: Context
    ) -> ServiceRunEntry {
        ServiceRunEntry(
            date: Date(),
            data: SharedWidgetData(
                siteName: "Service Centre",
                scheduledDate: Date(),
                tasksRemaining: 2,
                visitCount: 3
            )
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (
            ServiceRunEntry
        ) -> Void
    ) {
        let entry = ServiceRunEntry(
            date: Date(),
            data: WidgetDataStore.load()
        )

        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (
            Timeline<ServiceRunEntry>
        ) -> Void
    ) {
        let entry = ServiceRunEntry(
            date: Date(),
            data: WidgetDataStore.load()
        )

        let nextUpdate =
            Date().addingTimeInterval(
                1800
            )

        let timeline = Timeline(
            entries: [entry],
            policy: .after(
                nextUpdate
            )
        )

        completion(timeline)
    }
}

struct KenServiceRunWidgetEntryView: View {
    @Environment(\.widgetFamily)
    private var family

    let entry: ServiceRunEntry

    var body: some View {
        if family == .systemMedium {
            mediumView
        } else {
            smallView
        }
    }

    private var smallView: some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            Text("ServiceRun")
                .font(.headline)

            Spacer()

            if let siteName =
                entry.data.siteName {

                Text("Next Visit")
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )

                Text(siteName)
                    .font(.headline)
                    .lineLimit(2)

                if let scheduledDate =
                    entry.data.scheduledDate {

                    Text(
                        scheduledDate,
                        style: .time
                    )
                    .font(.subheadline)
                }

                Text(
                    "\(entry.data.tasksRemaining) tasks remaining"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )

            } else {
                Text("No visits today")
                    .font(.headline)

                Text(
                    "Your service run is clear."
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()
        }
        .containerBackground(
            .fill.tertiary,
            for: .widget
        )
    }

    private var mediumView: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack {
                Text("Today's Run")
                    .font(.headline)

                Spacer()

                Text(
                    "\(entry.data.visitCount) visits"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }

            Divider()

            if let siteName =
                entry.data.siteName {

                Text("Next Visit")
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )

                Text(siteName)
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    if let scheduledDate =
                        entry.data.scheduledDate {

                        Label(
                            scheduledDate.formatted(
                                date: .omitted,
                                time: .shortened
                            ),
                            systemImage: "clock"
                        )
                    }

                    Spacer()

                    Text(
                        "\(entry.data.tasksRemaining) tasks remaining"
                    )
                }
                .font(.caption)

            } else {
                Spacer()

                HStack {
                    Spacer()

                    VStack(
                        spacing: 6
                    ) {
                        Image(
                            systemName:
                                "calendar.badge.checkmark"
                        )
                        .font(.title2)

                        Text(
                            "No visits today"
                        )
                        .font(.headline)
                    }

                    Spacer()
                }

                Spacer()
            }
        }
        .containerBackground(
            .fill.tertiary,
            for: .widget
        )
    }
}

struct KenServiceRunWidget: Widget {
    let kind =
        "KenServiceRunWidget"

    var body:
        some WidgetConfiguration {

        StaticConfiguration(
            kind: kind,
            provider:
                ServiceRunProvider()
        ) { entry in

            KenServiceRunWidgetEntryView(
                entry: entry
            )
        }
        .configurationDisplayName(
            "ServiceRun"
        )
        .description(
            "Shows your next service visit."
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium
        ])
    }
}
