//
//  StrokeStyle-Timeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

extension StrokeStyle {
    static func getNormal(lineWidth: CGFloat) -> StrokeStyle {
        return StrokeStyle(lineWidth: lineWidth, lineCap: .round)
    }

    static func getDotted(lineWidth: CGFloat) -> StrokeStyle {
        return StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            dash: [10, 10],
            dashPhase: 0
        )
    }
}
