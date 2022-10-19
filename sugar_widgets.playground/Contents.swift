import UIKit

let session = URLSession.shared

let authJson: [String: Any] = ["accountName": "alix12488",
                           "password": "ab6407789",
                           "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]
var authRequest = dexcomRequest(with: authJson, method: "POST", endpoint: "General/AuthenticatePublisherAccount")

session.dataTask(with: authRequest, completionHandler: { data, response, error in
//    print(response, error)
    let accountId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
    let loginJson: [String: Any] = ["accountId": accountId ?? "",
                               "password": "ab6407789",
                               "applicationId": "d89443d2-327c-4a6f-89e5-496bbb0317db"]

    var loginRequest = dexcomRequest(with: loginJson, method: "POST", endpoint: "General/LoginPublisherAccountById")
    session.dataTask(with: loginRequest, completionHandler: { data, response, error in
//        print(response, error, data)
        let sessionId = String(data: data!, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
        print(sessionId)
        var readRequest = dexcomRequest(with: nil, method: "GET", endpoint: "Publisher/ReadPublisherLatestGlucoseValues?sessionId=\(sessionId ?? "")&minutes=10&maxCount=1")
        session.dataTask(with: readRequest, completionHandler: { data, response, error in
            print(response, error)
//            let json = try! JSONDecoder().decode([[String: String]].self, from: data!)
//            print(json)
        }).resume()
    }).resume()
}).resume()

func dexcomRequest(with json: [String: Any]?, method: String, endpoint: String) -> URLRequest {
    var request = URLRequest(url: URL(string: "https://share2.dexcom.com/ShareWebServices/Services/\(endpoint)")!)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
        request.httpBody = jsonData
    }
    return request
}
