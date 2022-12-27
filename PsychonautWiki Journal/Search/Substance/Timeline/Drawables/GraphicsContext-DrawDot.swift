//
//  GraphicsContext+DrawDot.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 22.12.22.
//

import SwiftUI

extension GraphicsContext {
    func drawDot(startX: Double, bottomY: Double, dotRadius: Double, color: Color) {
        fill(
            Path(ellipseIn: CGRect(x: startX-dotRadius, y: bottomY-dotRadius, width: dotRadius*2, height: dotRadius*2)),
            with: .color(color)
        )
    }
}
