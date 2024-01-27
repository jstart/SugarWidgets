//
//  DexcomService.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/19/22.
//

import Foundation

class DexcomService {
    
    private static let session = URLSession.shared
    static let shared = DexcomService()
    
    private let applicationId = "d89443d2-327c-4a6f-89e5-496bbb0317db"
    
    private var value: Int?
    private var directionValue: String?
    private var lastSuccess: Date?
    private var accountID: String?
    private var sessionID: String?
    
    init() {
        self.value = UserDefaults.standard.object(forKey: "value") as? Int
        self.directionValue = UserDefaults.standard.object(forKey: "directionValue") as? String
        self.lastSuccess = UserDefaults.standard.object(forKey: "lastSuccess") as? Date
        self.sessionID = UserDefaults.standard.object(forKey: "sessionID") as? String
    }
    
    func onAppear(completion: @escaping ((Int, LatestGlucoseValues.TrendDirections, Date) -> ())) {
        if let lastSuccess,
            (-lastSuccess.timeIntervalSinceNow) <= 5 * 60 {
            let direction = LatestGlucoseValues.TrendDirections(rawValue: directionValue ?? "") ?? .NotComputable

            completion(value ?? 0, direction, lastSuccess)
            return
        }
        
        let authJson: [String: String] = ["accountName": "alix12488",
                                          "password": "Ab6407789",
                                          "applicationId": applicationId]
        let authRequest = DexcomService.dexcomRequest(with: authJson, method: "POST", endpoint: "General/AuthenticatePublisherAccount")
        
        if sessionID != nil {
            self.fetchLatestReading(completion: completion)
            return
        }
        
        DexcomService.session.dataTask(with: authRequest, completionHandler: { data, response, error in
            guard error == nil else { return }
            self.accountID = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
            let loginJson: [String: String] = ["accountId": self.accountID ?? "",
                                               "password": "Ab6407789",
                                               "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]
            
            let loginRequest = DexcomService.dexcomRequest(with: loginJson, method: "POST", endpoint: "General/LoginPublisherAccountById")
            DexcomService.session.dataTask(with: loginRequest, completionHandler: { data, response, error in
                self.sessionID = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
                UserDefaults.standard.set(self.sessionID, forKey: "sessionID")
                self.fetchLatestReading(completion: completion)
            }).resume()
        }).resume()
    }
    
    private func fetchLatestReading(completion: @escaping ((Int, LatestGlucoseValues.TrendDirections, Date) -> ())) {
        let readRequest = DexcomService.dexcomRequest(with: nil, method: "GET", endpoint: "Publisher/ReadPublisherLatestGlucoseValues?sessionId=\(self.sessionID ?? "")&minutes=10&maxCount=1")
        DexcomService.session.dataTask(with: readRequest, completionHandler: { data, response, error in
            let json = try! JSONDecoder().decode([LatestGlucoseValues].self, from: data!)
            let value = json.first?.Value ?? 0
            let trendField = json.first?.Trend ?? ""
            let direction = LatestGlucoseValues.TrendDirections(rawValue: trendField) ?? .NotComputable
            
            self.value = value
            self.directionValue = trendField
            self.lastSuccess = Date()
            
            UserDefaults.standard.set(value, forKey: "value")
            UserDefaults.standard.set(trendField, forKey: "directionValue")
            UserDefaults.standard.set(Date(), forKey: "lastSuccess")
            completion(value, direction, Date())
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
