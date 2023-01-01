//
//  EverythingForOneLine.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 01.01.23.
//

import SwiftUI

struct EverythingForOneLine: Codable, Equatable {
    static func == (lhs: EverythingForOneLine, rhs: EverythingForOneLine) -> Bool {
        lhs.startTime == rhs.startTime
    }

    let roaDuration: RoaDuration?
    let startTime: Date
    let horizontalWeight: Double
    let verticalWeight: Double
    let color: SubstanceColor
}
