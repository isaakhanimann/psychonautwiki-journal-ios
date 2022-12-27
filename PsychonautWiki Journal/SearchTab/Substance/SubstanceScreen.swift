import SwiftUI

struct SubstanceScreen: View {

    let substance: Substance

    var body: some View {
        List {
            Group { // group is here because we cannot have more than 10 subviews
                if let articleURL = substance.url {
                    NavigationLink {
                        WebViewScreen(articleURL: articleURL)
                    } label: {
                        Label("Article", systemImage: "link")
                    }
                }
                if let summary = substance.summary {
                    NavigationLink("Summary") {
                        SummaryScreen(summary: summary)
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
                if let toxicities = substance.toxicities, !toxicities.isEmpty {
                    NavigationLink("Toxicity") {
                        ToxicityScreen(toxicities: toxicities)
                    }
                }
                let durationInfos = substance.durationInfos
                if !durationInfos.isEmpty {
                    NavigationLink("Duration") {
                        DurationScreen(durationInfos: durationInfos)
                    }
                }
            }
            Group {
                if let interactions = substance.interactions {
                    NavigationLink("Interactions") {
                        InteractionsScreen(
                            interactions: interactions,
                            substanceURL: substance.url
                        )
                    }
                }
                if let effects = substance.effectsSummary {
                    NavigationLink("Effects") {
                        EffectScreen(effect: effects)
                    }
                }
                if substance.generalRisks != nil || substance.longtermRisks != nil {
                    NavigationLink("Risks") {
                        RiskScreen(substance: substance)
                    }
                }
                if !substance.saferUse.isEmpty {
                    NavigationLink("Safer Use") {
                        SaferUseScreen(saferUse: substance.saferUse)
                    }
                }
                if let addictionPotential = substance.addictionPotential {
                    NavigationLink("Addiction Potential") {
                        AddictionScreen(addictionPotential: addictionPotential)
                    }
                }
            }
        }
        .navigationTitle(substance.name)
    }
}

struct SubstanceScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubstanceScreen(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!
            )
        }
    }
}
