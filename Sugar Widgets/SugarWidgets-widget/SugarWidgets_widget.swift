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
        SimpleEntry(value: 1, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        onAppear(completion: { bloodSugar in
            let entry = SimpleEntry(value: bloodSugar, configuration: configuration)
            completion(entry)
        })
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        onAppear(completion: { bloodSugar in
            let entry = SimpleEntry(value: bloodSugar, configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        })
    }
    
    func onAppear(completion: @escaping ((Int) -> Void)) {
        let session = URLSession.shared
        
        let authJson: [String: Any] = ["accountName": "alix12488",
                                       "password": "ab6407789",
                                       "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]
        let authRequest = dexcomRequest(with: authJson, method: "POST", endpoint: "General/AuthenticatePublisherAccount")
        
        session.dataTask(with: authRequest, completionHandler: { data, response, error in
            let accountId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
            let loginJson: [String: Any] = ["accountId": accountId ?? "",
                                            "password": "ab6407789",
                                            "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]
            
            let loginRequest = dexcomRequest(with: loginJson, method: "POST", endpoint: "General/LoginPublisherAccountById")
            session.dataTask(with: loginRequest, completionHandler: { data, response, error in
                let sessionId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
                let readRequest = dexcomRequest(with: nil, method: "GET", endpoint: "Publisher/ReadPublisherLatestGlucoseValues?sessionId=\(sessionId ?? "")&minutes=10&maxCount=1")
                session.dataTask(with: readRequest, completionHandler: { data, response, error in
                    let json = try! JSONDecoder().decode([LatestGlucoseValues].self, from: data!)
                    let bloodSugar = json.first?.Value ?? 0
                    completion(bloodSugar)
                }).resume()
            }).resume()
        }).resume()
    }
        
    func dexcomRequest(with json: [String: Any]?, method: String, endpoint: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://share2.dexcom.com/ShareWebServices/Services/\(endpoint)")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let json = json, let jsonData = try? JSONSerialization.data(withJSONObject: json) {
            request.httpBody = jsonData
        }
        return request
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    let value: Int
    let configuration: ConfigurationIntent
}

struct SugarWidgets_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.value)")
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryInline, .accessoryCircular, .accessoryRectangular, .systemExtraLarge, .systemSmall, .systemMedium, .systemLarge])
    }
}

struct LatestGlucoseValues: Codable {
    var WT: String
    var ST: String
    var DT: String
    var Value: Int
    var Trend: String
}

struct SugarWidgets_widget_Previews: PreviewProvider {
    static var previews: some View {
        SugarWidgets_widgetEntryView(entry: SimpleEntry(value: 1, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
