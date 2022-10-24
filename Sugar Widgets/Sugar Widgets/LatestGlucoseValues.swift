//
//  LatestGlucoseValues.swift
//  Sugar Widgets
//
//  Created by Christopher Truman on 10/19/22.
//

import Foundation

struct LatestGlucoseValues: Codable {
// https://github.com/gagebenne/pydexcom/blob/main/pydexcom/const.py
    enum TrendDirections: String {
        case None
        case DoubleUp
        case SingleUp
        case FortyFiveUp
        case Flat
        case FortyFiveDown
        case SingleDown
        case DoubleDown
        case NotComputable
        case RateOutOfRange
        
        var trendDiscriptions: String {
            switch self {
            case .None:
                return ""
            case .DoubleUp:
                return "rising quickly"
            case .SingleUp:
                return "rising"
            case .FortyFiveUp:
                return "rising slightly"
            case .Flat:
                return "steady"
            case .FortyFiveDown:
                return "falling slightly"
            case .SingleDown:
                return "falling"
            case .DoubleDown:
                return "falling quickly"
            case .NotComputable:
                return "unable to determine trend"
            case .RateOutOfRange:
                return "trend unavailable"
            }
        }
        
        var arrow: String {
            switch self {
            case .None:
                return ""
            case .DoubleUp:
                return "↑↑"
            case .SingleUp:
                return "↑"
            case .FortyFiveUp:
                return "↗"
            case .Flat:
                return "↗"
            case .FortyFiveDown:
                return "↘"
            case .SingleDown:
                return "↓"
            case .DoubleDown:
                return "↓↓"
            case .NotComputable, .RateOutOfRange:
                return "?"
            }
        }
    }
    
    var WT: String
    var ST: String
    var DT: String
    var Value: Int
    var Trend: String
}
