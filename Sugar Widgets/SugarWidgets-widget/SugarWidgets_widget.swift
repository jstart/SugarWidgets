//
//  SugarWidgets_widget.swift
//  SugarWidgets-widget
//
//  Created by Christopher Truman on 10/18/22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(value: 120, trend: LatestGlucoseValues.TrendDirections.DoubleUp.arrow, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        DexcomService().onAppear(completion: { bloodSugar, direction in
            var trend = ""
            switch context.family {
            case .systemSmall, .accessoryCircular:
                break;
            case .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryRectangular:
                trend = direction.arrow
            @unknown default:
                break;
            }
            let entry = SimpleEntry(value: bloodSugar, trend: trend, configuration: configuration)
            completion(entry)
        })
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        DexcomService().onAppear(completion: { bloodSugar, direction in
            var trend = ""
            switch context.family {
            case .systemSmall, .accessoryCircular:
                break;
            case .systemMedium, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryRectangular:
                trend = direction.arrow
            @unknown default:
                break;
            }
            let entry = SimpleEntry(value: bloodSugar, trend: trend, configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        })
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    let value: Int
    let trend: String
    let configuration: ConfigurationIntent
}

struct SugarWidgets_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.trend) \(entry.value)")
            .font(.largeTitle)
    }
}

@main
struct SugarWidgets_widget: Widget {
    let kind: String = "SugarWidgets_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SugarWidgets_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Glucose Tracker")
        .description("Displays updated glucose readings from your Dexcom.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .systemExtraLarge, .systemSmall, .systemMedium, .systemLarge])
    }
}

struct SugarWidgets_widget_Previews: PreviewProvider {
    static var previews: some View {
        SugarWidgets_widgetEntryView(entry: SimpleEntry(value: 1, trend: LatestGlucoseValues.TrendDirections.DoubleUp.arrow, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
