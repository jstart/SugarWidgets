//
//  WatchWidget.swift
//  WatchWidget
//
//  Created by Christopher Truman on 10/18/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        var entry: SimpleEntry?
        let defaultEntry = SimpleEntry(value: 120, trend: "")
        switch context.family {
        case .accessoryCorner, .accessoryCircular:
            let entry = SimpleEntry(value: 120, trend:  LatestGlucoseValues.TrendDirections.DoubleUp.arrow)
        case .accessoryRectangular,.accessoryInline:
            entry = defaultEntry
        @unknown default:
            entry = defaultEntry
        }
        return entry ?? defaultEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        DexcomService().onAppear(completion: { bloodSugar, direction in
            var entry: SimpleEntry?
            let defaultEntry = SimpleEntry(value: bloodSugar, trend: "")
            switch context.family {
            case .accessoryCorner,.accessoryCircular:
                let entry = SimpleEntry(value: bloodSugar, trend: direction.arrow)
            case .accessoryRectangular,.accessoryInline:
                entry = defaultEntry
            @unknown default:
                entry = defaultEntry
            }
            completion(entry ?? defaultEntry)
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        DexcomService().onAppear(completion: { bloodSugar, direction in
            let entry = SimpleEntry(value: bloodSugar, trend: direction.arrow)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    let value: Int
    let trend: String
}

struct SugarWidgets_watchEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.trend) \(entry.value)")
            .font(.largeTitle)
    }
}

@main
struct SugarWidgets_watch: Widget {
    let kind: String = "SugarWidgets_watch"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SugarWidgets_watchEntryView(entry: entry)
        }
        .configurationDisplayName("Glucose Tracker")
        .description("Displays updated glucose readings from your Dexcom.")
    }
}

struct SugarWidgets_watch_Previews: PreviewProvider {
    static var previews: some View {
        SugarWidgets_watchEntryView(entry: SimpleEntry(value: 240, trend: LatestGlucoseValues.TrendDirections.DoubleUp.arrow))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        SugarWidgets_watchEntryView(entry: SimpleEntry(value: 240, trend: ""))
            .previewContext(WidgetPreviewContext(family: .accessoryCorner))
    }
}
