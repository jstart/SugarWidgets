//
//  ContentView.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/18/22.
//

import SwiftUI

struct ContentView: View {
    @State var bloodSugar: Int = 0
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world! \(bloodSugar)")
        }
        .padding()
        .onAppear(perform: { onAppear() })
    }
    
    func onAppear() {
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
                    bloodSugar = json.first?.Value ?? 0
                }).resume()
            }).resume()
        }).resume()
        
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
}

struct LatestGlucoseValues: Codable {
    var WT: String
    var ST: String
    var DT: String
    var Value: Int
    var Trend: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
