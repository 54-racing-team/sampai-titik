//
//  Font.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 27/08/26.
//

import Foundation
import SwiftUI

extension Font {
    static func montserrat(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        let name = "Montserrat-Medium"
        if UIFont(name: name, size: size) != nil {
            return Font.custom(name, size: size)
        } else {
            return Font.system(size: size, weight: weight, design: .rounded)
        }
    }
}
