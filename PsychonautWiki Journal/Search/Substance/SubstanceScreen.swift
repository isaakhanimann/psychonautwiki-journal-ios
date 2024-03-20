// Copyright (c) 2022. Isaak Hanimann.
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

struct SubstanceScreen: View {
    let substance: Substance

    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        List {
            if !substance.isApproved {
                Section {
                    Text("Info Not PW Approved")
                }
            }
            Group {
                Group { // group is here because we cannot have more than 10 subviews
                    if let summary = substance.summary {
                        Section("Summary") {
                            VStack {
                                Text(summary)
                                if !substance.categories.isEmpty {
                                    CategorySection(substance: substance)
                                }
                            }
                        }
                    } else {
                        if !substance.categories.isEmpty {
                            Section("Categories") {
                                CategorySection(substance: substance)
                            }
                        }
                    }
                    if let effects = substance.effectsSummary {
                        Section("Effects") {
                            Text(effects)
                        }
                    }
                }
                Group {
                    if substance.dosageRemark != nil || !substance.doseInfos.isEmpty {
                        DosesSection(substance: substance)
                    }
                    let durationInfos = substance.durationInfos
                    if !durationInfos.isEmpty {
                        DurationSection(substance: substance)
                    }
                    if let interactions = substance.interactions {
                        Section("Interactions") {
                            InteractionsGroup(
                                interactions: interactions,
                                substance: substance
                            )
                        }
                    }
                    if substance.tolerance != nil || !substance.crossTolerances.isEmpty {
                        ToleranceSection(substance: substance)
                    }
                    if !substance.toxicities.isEmpty {
                        ToxicitySection(substance: substance)
                    }
                }
                Group {
                    if let acute = substance.generalRisks {
                        Section("Acute Risk") {
                            Text(acute)
                        }
                    }
                    if let longTerm = substance.longtermRisks {
                        Section("Long-term Risk") {
                            Text(longTerm)
                        }
                    }
                    if !substance.saferUse.isEmpty {
                        Section("Safer Use") {
                            ForEach(substance.saferUse, id: \.self) { point in
                                Text(point)
                            }
                        }
                    }
                    if let addictionPotential = substance.addictionPotential {
                        Section("Addiction Potential") {
                            Text(addictionPotential)
                        }
                    }
                }
            }

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Article", value: GlobalNavigationDestination.webView(articleURL: substance.url))
            }
        }
        .fullScreenCover(isPresented: $isShowingAddIngestionSheet) {
            NavigationStack {
                AcknowledgeInteractionsView(substance: substance) {
                    isShowingAddIngestionSheet.toggle()
                }
            }
        }
        .navigationTitle(substance.name)
    }
}

#Preview {
    NavigationStack {
        SubstanceScreen(
            substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!
        )
    }
}
