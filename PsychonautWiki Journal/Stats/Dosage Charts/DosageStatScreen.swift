// Copyright (c) 2024. Isaak Hanimann.
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
import Charts

struct DosageStatScreen: View {

    let substanceName: String
    let unit: String
    let substanceColor: SubstanceColor

    init(substanceName: String) {
        self.substanceName = substanceName
        let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
        let roaDose = substance?.roas.first?.dose
        if let roaUnit = roaDose?.units {
            unit = roaUnit
        } else {
            if let customSubstance = PersistenceController.shared.getCustomSubstance(name: substanceName) {
                unit = customSubstance.unitsUnwrapped
            } else {
                unit = ""
            }
        }
        unknownDoseEstimate = roaDose?.commonMin ?? 0
        substanceColor = getColor(for: substanceName)
        self.ingestions = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "consumerName=nil OR consumerName=''"),
                NSPredicate(format: "substanceName == %@", substanceName)
            ]))
    }

    private var ingestions: FetchRequest<Ingestion>
    @State private var unknownDoseEstimate = 0.0


    var body: some View {
        List {
            if let last30Days = dosageStat?.last30Days {
                Section {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("\(substanceName) Dosage")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("Last 30 Days")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        Chart(last30Days, id: \.day) {
                            BarMark(
                                x: .value("Day", $0.day, unit: .day),
                                y: .value("Dosage", $0.dosage)
                            )
                            .foregroundStyle(substanceColor.swiftUIColor)
                        }.chartYAxisLabel("Dosage in \(unit)")
                            .frame(height: 240)
                    }
                }
            } else {
                Text("No \(substanceName) ingestions in last 30 days")
            }

            Section("Estimate unknown doses as") {
                HStack  {
                    TextField(
                        "Unknown doses estimated as",
                        value: $unknownDoseEstimate,
                        format: .number).keyboardType(.decimalPad)
                    Text(unit)
                }
            }

            Section {
                Text("Disclaimer, this will not work if you tracked one substance with different pure units, not custom units")
            }
        }
        .onAppear {
            calculateStats()
        }
        .onChange(of: ingestions.wrappedValue.count, perform: { _ in
            calculateStats()
        })
        .onChange(of: unknownDoseEstimate) { newValue in
            calculateStats()
        }
    }

    @State private var dosageStat: DosageStat?

    struct InstanceDosage {
        let day: Date
        let dosage: Double
    }

    private func calculateStats() {
        let last30Days = ingestions.wrappedValue.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: .now) <= 30
        }

        let instanceDosages = last30Days.map { ing in
            InstanceDosage(day: ing.timeUnwrapped, dosage: ing.pureSubstanceDose ?? unknownDoseEstimate)
        }

        let instanceDosagesGroupedByDay = Dictionary(grouping: instanceDosages) { instanceDose in
            let components = Calendar.current.dateComponents([.day, .month], from: instanceDose.day)
            if let day = components.day, let month = components.month {
                return String(day) + String(month)
            } else {
                return ""
            }
        }

        let dayDosages = instanceDosagesGroupedByDay.compactMap { (_: String, instanceDosages: [InstanceDosage]) in
            let summedDosage = instanceDosages.map({$0.dosage}).reduce(0.0, +)
            if let day = instanceDosages.first?.day, summedDosage > 0 {
                return DayDosage(day: day, dosage: summedDosage)
            } else {
                return nil
            }
        }

        dosageStat = DosageStat(
            last30Days: dayDosages,
            last26Weeks: [],
            last12Months: [],
            years: [])



    }
}

#Preview {
    DosageStatScreen(substanceName: "MDMA")
}
