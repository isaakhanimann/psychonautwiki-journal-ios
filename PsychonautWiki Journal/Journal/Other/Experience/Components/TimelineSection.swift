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

    let timelineModel: TimelineModel?
    let hiddenIngestions: [ObjectIdentifier]
    let ingestionsSorted: [Ingestion]
    let timeDisplayStyle: TimeDisplayStyle
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    let showIngestion: (ObjectIdentifier) -> Void
    let hideIngestion: (ObjectIdentifier) -> Void
    let updateActivityIfActive: () -> Void

    var body: some View {
        Group {
            let timelineHeight: Double = 200
            if let timelineModel {
                NavigationLink {
                    TimelineScreen(timelineModel: timelineModel)
                } label: {
                    EffectTimeline(timelineModel: timelineModel, height: timelineHeight)
                }
            } else {
                Canvas {_,_ in }.frame(height: timelineHeight)
            }
            ForEach(ingestionsSorted) { ing in
                let isIngestionHidden = hiddenIngestions.contains(ing.id)
                NavigationLink {
                    EditIngestionScreen(
                        ingestion: ing,
                        isEyeOpen: isEyeOpen
                    ).onDisappear {
                        updateActivityIfActive()
                    }
                } label: {
                    HStack(alignment: .center) {
                        if isIngestionHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
                        IngestionRow(
                            ingestion: ing,
                            firstIngestionTime: ingestionsSorted.first?.time,
                            timeDisplayStyle: timeDisplayStyle,
                            isEyeOpen: isEyeOpen,
                            isHidingDosageDots: isHidingDosageDots
                        )
                    }
                    .swipeActions(edge: .leading) {
                        if isIngestionHidden {
                            Button {
                                showIngestion(ing.id)
                            } label: {
                                Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                            }
                        } else {
                            Button {
                                hideIngestion(ing.id)
                            } label: {
                                Label("Hide", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            PersistenceController.shared.viewContext.delete(ing)
                            PersistenceController.shared.saveViewContext()
                            updateActivityIfActive()
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
    }
}
