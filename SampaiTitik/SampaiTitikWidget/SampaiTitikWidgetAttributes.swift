//
//  SampaiTitikWidgetAttributes.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import ActivityKit
import SwiftUI

struct SampaiTitikWidgetAttributes: ActivityAttributes {
    //for dynamic data store it in the ContentState
    public struct ContentState: Codable, Hashable {
        var currentStation: String
        var nextStation: String
        var progress: Double
    }
    
    //static data
    var trainLine: String
}
