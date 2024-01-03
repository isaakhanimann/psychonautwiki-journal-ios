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
                Section("Info Not PW Approved") {
                    sectionContent
                }
            } else {
                Section {
                    sectionContent
                }
            }
        }
        .font(.headline)
        .fullScreenCover(isPresented: $isShowingAddIngestionSheet) {
            NavigationStack {
                AcknowledgeInteractionsView(substance: substance) {
                    isShowingAddIngestionSheet.toggle()
                }
            }
        }
        .dismissWhenTabTapped()
        .navigationTitle(substance.name)
    }

    private var addIngestionButton: some View {
        Button {
            isShowingAddIngestionSheet.toggle()
        } label: {
            Label("New Ingestion", systemImage: "plus.circle.fill")
                .labelStyle(.titleAndIcon)
                .font(.headline)
        }
    }

    private var sectionContent: some View {
        Group {
            Group { // group is here because we cannot have more than 10 subviews
                NavigationLink {
                    WebViewScreen(articleURL: substance.url)
                } label: {
                    Label("Article", systemImage: "link")
                }
                if let summary = substance.summary {
                    NavigationLink("Summary") {
                        SummaryScreen(substanceName: substance.name, summary: summary)
                    }
                }
                if !substance.categories.isEmpty {
                    NavigationLink("Categories") {
                        CategoryScreen(substance: substance)
                    }
                }
            }
            Group {
                if substance.dosageRemark != nil || !substance.doseInfos.isEmpty {
                    NavigationLink("Dosage") {
                        DosesScreen(substance: substance)
                    }
                }
                if substance.tolerance != nil || !substance.crossTolerances.isEmpty {
                    NavigationLink("Tolerance") {
                        ToleranceScreen(substance: substance)
                    }
                }
                if !substance.toxicities.isEmpty {
                    NavigationLink("Toxicity") {
                        ToxicityScreen(
                            substanceName: substance.name,
                            toxicities: substance.toxicities,
                            substanceURL: substance.url
                        )
                    }
                }
                let durationInfos = substance.durationInfos
                if !durationInfos.isEmpty {
                    NavigationLink("Duration") {
                        DurationScreen(
                            substanceName: substance.name,
                            durationInfos: durationInfos
                        )
                    }
                }
            }
            Group {
                if let interactions = substance.interactions {
                    NavigationLink("Interactions") {
                        InteractionsScreen(
                            substanceName: substance.name,
                            interactions: interactions,
                            substanceURL: substance.url
                        )
                    }
                }
                if let effects = substance.effectsSummary {
                    NavigationLink("Effects") {
                        EffectScreen(substanceName: substance.name, effect: effects)
                    }
                }
                if substance.generalRisks != nil || substance.longtermRisks != nil {
                    NavigationLink("Risks") {
                        RiskScreen(substance: substance)
                    }
                }
                if !substance.saferUse.isEmpty {
                    NavigationLink("Safer Use") {
                        SaferUseScreen(substance: substance)
                    }
                }
                if let addictionPotential = substance.addictionPotential {
                    NavigationLink("Addiction Potential") {
                        AddictionScreen(
                            substanceName: substance.name,
                            addictionPotential: addictionPotential
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SubstanceScreen(
            substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!
        )
        .environmentObject(TabBarObserver())
    }
}
