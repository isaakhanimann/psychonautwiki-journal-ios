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

final class HudState: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var substanceName: String = ""
    @Published var interactions: [InteractionWith] = []
    private var dismissWork: DispatchWorkItem?

    func show(substanceName: String, interactions: [Interaction]) {
        dismissWork?.cancel()
        withAnimation {
            self.substanceName = substanceName
            self.interactions = interactions.compactMap({ i in
                if i.aName != substanceName {
                    return InteractionWith(name: i.aName, interactionType: i.interactionType)
                } else if i.bName != substanceName {
                    return InteractionWith(name: i.bName, interactionType: i.interactionType)
                } else {
                    return nil
                }
            })
            self.isPresented = true
        }
        dismissWork = DispatchWorkItem { [weak self] in
            withAnimation {
                self?.isPresented = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: dismissWork!)
    }
}
