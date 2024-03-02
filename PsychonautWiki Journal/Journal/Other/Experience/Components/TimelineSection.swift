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

struct TimelineSection: View {
    let timelineModel: TimelineModel
    let ingestionsSorted: [Ingestion]
    let timeDisplayStyle: TimeDisplayStyle
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    let hiddenIngestions: [ObjectIdentifier]
    let showIngestion: (ObjectIdentifier) -> Void
    let hideIngestion: (ObjectIdentifier) -> Void
    let updateActivityIfActive: () -> Void

    @State private var ingestionToEdit: Ingestion?

    var body: some View {
        Group {
            let timelineHeight: Double = 200
            NavigationLink {
                TimelineScreen(timelineModel: timelineModel)
            } label: {
                EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
            }
            ForEach(ingestionsSorted) { ing in
                Button {
                    ingestionToEdit = ing
                } label: {
                    HStack(alignment: .center) {
                        IngestionRow(
                            ingestion: ing,
                            firstIngestionTime: ingestionsSorted.first?.time,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots
                        )
                        let isIngestionHidden = hiddenIngestions.contains(ing.id)
                        if isIngestionHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }.sheet(item: $ingestionToEdit, onDismiss: {
            updateActivityIfActive()
        }) { ingestion in
            let isHidden = Binding(
                get: { hiddenIngestions.contains(ingestion.id) },
                set: { newIsHidden in
                    if newIsHidden {
                        hideIngestion(ingestion.id)
                    } else {
                        showIngestion(ingestion.id)
                    }
                }
            )
            EditIngestionScreen(
                ingestion: ingestion,
                isHidden: isHidden)
        }
    }
}
