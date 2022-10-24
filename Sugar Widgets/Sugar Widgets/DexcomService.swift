//
//  DexcomService.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/19/22.
//

import Foundation

class DexcomService {
    private static let session = URLSession.shared
    private let applicationId = "d89443d2-327c-4a6f-89e5-496bbb0317db"
    
    func onAppear(completion: @escaping ((Int, LatestGlucoseValues.TrendDirections) -> ())) {
        let authJson: [String: Any] = ["accountName": "alix12488",
                                       "password": "Ab6407789",
                                       "applicationId": applicationId]
        let authRequest = DexcomService.dexcomRequest(with: authJson, method: "POST", endpoint: "General/AuthenticatePublisherAccount")
        
        DexcomService.session.dataTask(with: authRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            let accountId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
            let loginJson: [String: Any] = ["accountId": accountId ?? "",
                                            "password": "Ab6407789",
                                            "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]
            
            let loginRequest = DexcomService.dexcomRequest(with: loginJson, method: "POST", endpoint: "General/LoginPublisherAccountById")
            DexcomService.session.dataTask(with: loginRequest, completionHandler: { data, response, error in
                let sessionId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
                let readRequest = DexcomService.dexcomRequest(with: nil, method: "GET", endpoint: "Publisher/ReadPublisherLatestGlucoseValues?sessionId=\(sessionId ?? "")&minutes=10&maxCount=1")
                DexcomService.session.dataTask(with: readRequest, completionHandler: { data, response, error in
                    let json = try! JSONDecoder().decode([LatestGlucoseValues].self, from: data!)
                    let value = json.first?.Value ?? 0
                    let trendField = json.first?.Trend ?? ""
                    let direction = LatestGlucoseValues.TrendDirections(rawValue: trendField) ?? .NotComputable
                    completion(value, direction)
                }).resume()
            }).resume()
        }).resume()
    }
        
    private static func dexcomRequest(with json: [String: Any]?, method: String, endpoint: String) -> URLRequest {
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
