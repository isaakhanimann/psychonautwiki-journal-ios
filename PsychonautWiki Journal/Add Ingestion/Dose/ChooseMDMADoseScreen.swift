//
//  ChooseMDMADoseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI

struct ChooseMDMADoseScreen: View {
    let dismiss: () -> Void
    let mdma = SubstanceRepo.shared.getSubstance(name: "MDMA")!
    var oralDose: RoaDose {
        mdma.getDose(for: .oral)!
    }
    @State private var mdmaDoseInMg = 100.0
    @State private var bodyWeightInKg = 75.0
    @State private var isEstimate = false
    @State private var gender = Gender.male

    let units = "mg"

    private var suggestedMaxDoseInMg: Double {
        bodyWeightInKg * gender.mgPerKg
    }

    private var suggestedMaxDoseRounded: Double {
        round(suggestedMaxDoseInMg)
    }

    private var suggestedDoseText: String {
        "\(Int(suggestedMaxDoseRounded)) \(units)"
    }

    private var doseRounded: Double {
        round(mdmaDoseInMg)
    }

    private var doseText: String {
        String(Int(doseRounded))
    }

    enum Gender {
        case male
        case female

        var mgPerKg: Double {
            switch self {
            case .male:
                return 1.5
            case .female:
                return 1.3
            }
        }
    }

    var body: some View {
        Form {
            Section("Max Recommended") {
                VStack {
                    Text(suggestedDoseText).font(.title.bold())
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(Gender.male)
                        Text("Female").tag(Gender.female)
                    }.pickerStyle(.segmented)
                    Text("\(Int(bodyWeightInKg)) kg").font(.title2.bold())
                    Slider(
                        value: $bodyWeightInKg,
                        in: 40...150,
                        step: 5
                    ) {
                        Text("Body Weight")
                    } minimumValueLabel: {
                        Text("40")
                    } maximumValueLabel: {
                        Text("150")
                    }
                }
                Button("Choose Max Recommended") {
                    mdmaDoseInMg = suggestedMaxDoseInMg
                }
            }
            Section("Choice") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: mdmaDoseInMg, with: units)
                    Text("\(doseText) mg")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                    Slider(
                        value: $mdmaDoseInMg,
                        in: 10...400,
                        step: 10
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("10")
                    } maximumValueLabel: {
                        Text("400")
                    }
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
            }
            if #available(iOS 16, *) {
                Section("Desirable vs Adverse Effects") {
                    MDMADesirableVsAdverseChart().frame(height: 200)
                }
            }
            Section("Pills") {
                Text("You cannot determine the MDMA content of pills visually. E.g. pills that looked the same had differences of 220 mg in Switzerland in 2021. To determine the contents of your pills you need to test your substances quantitatively in free and anonymous testing centers.")
                Link("EMCDDA Statistics", destination: URL(string: "https://www.emcdda.europa.eu/data/stats2022/ppp_en")!)
                Group {
                    VStack(alignment: .leading) {
                        Text("Average Pill Switzerland 2021")
                        Text("175 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Switzerland 2021")
                        Text("300 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Weakest Pill Switzerland 2021")
                        Text("50 mg").font(.headline)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Average Pill Netherlands 2020")
                        Text("160 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Netherlands 2020")
                        Text("310 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Weakest Pill Netherlands 2020")
                        Text("1 mg").font(.headline)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Strongest Pill UK 2014")
                        Text("400 mg").font(.headline)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Average Pill Belgium 2019")
                        Text("130 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Belgium 2019")
                        Text("410 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Belgium 2005")
                        Text("155 mg").font(.headline)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Germany 2018")
                        Text("210 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Germany 2017")
                        Text("450 mg").font(.headline)
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        Text("Average Pill Italy 2020")
                        Text("170 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Strongest Pill Italy 2020")
                        Text("280 mg").font(.headline)
                    }
                    VStack(alignment: .leading) {
                        Text("Average Pill Italy 2007")
                        Text("20 mg").font(.headline)
                    }
                }
            }
        }
        .navigationTitle("MDMA Dosage")
        .headerProminence(.increased)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                NavigationLink("Unknown Dose") {
                    FinishIngestionScreen(
                        substanceName: mdma.name,
                        administrationRoute: .oral,
                        dose: nil,
                        units: units,
                        isEstimate: false,
                        dismiss: dismiss
                    )
                }
                NavigationLink {
                    FinishIngestionScreen(
                        substanceName: mdma.name,
                        administrationRoute: .oral,
                        dose: doseRounded,
                        units: units,
                        isEstimate: isEstimate,
                        dismiss: dismiss
                    )
                } label: {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
            }
        }
    }
}

struct ChooseMDMADoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseMDMADoseScreen(dismiss: {})
        }
    }
}
