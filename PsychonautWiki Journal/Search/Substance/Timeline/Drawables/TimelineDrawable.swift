//
//  TimelineDrawable.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

protocol TimelineDrawable {
    var width: TimeInterval {get}

    func drawTimeLineWithShape(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    )
}
