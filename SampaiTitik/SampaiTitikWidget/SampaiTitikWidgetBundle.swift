//
//  SampaiTitikWidgetBundle.swift
//  SampaiTitikWidget
//
//  Created by Ahmad Yasri Zaenuri on 07/09/26.
//

import WidgetKit
import SwiftUI

@main
struct SampaiTitikWidgetBundle: WidgetBundle {
    var body: some Widget {
        SampaiTitikWidget()
        SampaiTitikWidgetControl()
        SampaiTitikWidgetLiveActivity()
    }
}
