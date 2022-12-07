import SwiftUI

struct SubstanceView: View {

    let substance: Substance

    var body: some View {
        List {
            if let summary = substance.summary {
                Text(summary)
            }
            ForEach(substance.categories, id: \.self) { category in
                NavigationLink {
                    CategoryExplanationScreen(categoryName: category)
                } label: {
                    Text(category)
                }
            }
            if let articleURL = substance.url {
                NavigationLink {
                    WebViewScreen(articleURL: articleURL)
                } label: {
                    Label("Article", systemImage: "link")
                }
            }
            Group {
                let roaDoses: [DoseInfo] = substance.roas.compactMap({ roa in
                    if let dose = roa.dose {
                        return DoseInfo(
                            route: roa.name.rawValue.localizedCapitalized,
                            roaDose: dose,
                            bioavailability: roa.bioavailability
                        )
                    } else {
                        return nil
                    }
                })
                if substance.dosageRemark != nil || !roaDoses.isEmpty {
                    Section("Dosage") {
                        if let dosageRemark = substance.dosageRemark {
                            Text(dosageRemark)
                        }
                        ForEach(roaDoses, id: \.route) { dose in
                            VStack(alignment: .leading) {
                                Text(dose.route).font(.headline)
                                DoseView(roaDose: dose.roaDose)
                                if let bio = dose.bioavailability?.displayString {
                                    RowLabelView(label: "Bioavailability", value: "\(bio)%")
                                }
                            }
                        }
                    }
                }
                if substance.tolerance != nil || !substance.crossTolerances.isEmpty {
                    Section("Tolerance") {
                        if let full = substance.tolerance?.full {
                            RowLabelView(label: "full", value: full)
                        }
                        if let half = substance.tolerance?.half {
                            RowLabelView(label: "half", value: half)
                        }
                        if let zero = substance.tolerance?.zero {
                            RowLabelView(label: "zero", value: zero)
                        }
                        let crossTolerances = substance.crossTolerances.joined(separator: ", ")
                        if !crossTolerances.isEmpty {
                            Text("Cross tolerance with \(crossTolerances)")
                        }
                    }
                }
                if let toxicities = substance.toxicities, !toxicities.isEmpty {
                    Section("Toxicity") {
                        VStack {
                            ForEach(toxicities, id: \.self) { toxicity in
                                Text(toxicity)
                            }
                        }
                    }
                }

                if !substance.durationInfos.isEmpty {
                    DurationSection(durationInfos: substance.durationInfos)
                }
            }
            InteractionsSection(substance: substance)
            Group { // group is here because we cannot have more than 10 subviews
                if let effects = substance.effectsSummary {
                    Section("Effects") {
                        Text(effects)
                    }
                }
                if let risks = substance.generalRisks {
                    Section("Risks") {
                        Text(risks)
                    }
                }
                if let longtermRisks = substance.longtermRisks {
                    Section("Longterm Risks") {
                        Text(longtermRisks)
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
        .navigationTitle(substance.name)
    }
}

struct SubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubstanceView(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!
            )
        }
    }
}

struct DoseInfo {
    let route: String
    let roaDose: RoaDose
    let bioavailability: RoaRange?
}
