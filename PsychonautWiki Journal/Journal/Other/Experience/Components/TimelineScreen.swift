// Copyright (c) 2023. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at 
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct TimelineScreen: View {
    let timelineModel: TimelineModel
    @State private var zoomLevel = 1.0
    @State private var isOrientationLandscape = false

    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack {
                        Spacer()
                        EffectTimeline(timelineModel: timelineModel, height: isOrientationLandscape ? geo.size.height : 300)
                            .frame(width: geo.size.width * zoomLevel)
                        Spacer()
                    }
                }
            }
            Slider(value: $zoomLevel, in: 1...6) {
                Text("Zoom Level")
            }
            .padding(.bottom, isOrientationLandscape ? 0 : 100)
        }
        .padding(.horizontal)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            checkCurrentOrientation()
        }
        .onAppear {
            checkCurrentOrientation()
        }
        .navigationTitle("Effect Timeline")
    }

    private func checkCurrentOrientation() {
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            isOrientationLandscape = true
        } else if deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown {
            isOrientationLandscape = false
        }
    }
}

struct TimelineScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineScreen(timelineModel: TimelineModel(
                everythingForEachLine: EffectTimeline_Previews.everythingForEachLine,
                everythingForEachRating: EffectTimeline_Previews.everythingForEachRating
            ))
        }
    }
}
