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
    @State private var isAverageShown = false

    enum StatTimeRangeOption: String, CaseIterable {
        case last30Days = "30D"
        case last26Weeks = "26W"
        case last12Months = "12M"
        case allYears = "Y"
    }

    @State private var selectedTimeRangeOption = StatTimeRangeOption.last26Weeks

    var body: some View {
        List {
            if doAllIngestionsHaveSameUnitEqualToSubstance {
                Section {
                    Picker("Time range", selection: $selectedTimeRangeOption) {
                        ForEach(StatTimeRangeOption.allCases, id: \.rawValue) { timeRange in
                            Text(timeRange.rawValue).tag(timeRange)
                        }
                    }.pickerStyle(.segmented)

                    switch selectedTimeRangeOption {
                    case .last30Days:
                        DosageStatDayChart(
                            last30Days: dosageStat?.last30Days ?? [],
                            substanceName: substanceName,
                            substanceColor: substanceColor,
                            unit: unit,
                            isAverageShown: isAverageShown
                        )
                    case .last26Weeks:
                        DosageStatWeekChart(
                            last26Weeks: dosageStat?.last26Weeks ?? [],
                            substanceName: substanceName,
                            substanceColor: substanceColor,
                            unit: unit,
                            isAverageShown: isAverageShown
                        )
                    case .last12Months:
                        DosageStatMonthChart(
                            last12Months: dosageStat?.last12Months ?? [],
                            substanceName: substanceName,
                            substanceColor: substanceColor,
                            unit: unit,
                            isAverageShown: isAverageShown
                        )
                    case .allYears:
                        DosageStatYearChart(
                            years: dosageStat?.years ?? [],
                            substanceName: substanceName,
                            substanceColor: substanceColor,
                            unit: unit,
                            isAverageShown: isAverageShown
                        )
                    }
                }.listRowSeparator(.hidden)

                Section {
                    Toggle("Show Average", isOn: $isAverageShown).tint(.accentColor)
                }

                if areThereUnknownDoses {
                    Section("Estimate unknown doses as") {
                        HStack  {
                            TextField(
                                "Unknown dose estimate",
                                value: $unknownDoseEstimate,
                                format: .number).keyboardType(.decimalPad)
                            Text(unit)
                        }
                    }
                }
            } else {
                Section {
                    Text("Not all your ingestions of \(substanceName) are using \(unit) as their pure unit. It's therefore not possible to sum those doses together to show a graph.")
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(substanceName)
        .onAppear {
            updateStats()
        }
        .onChange(of: ingestions.wrappedValue.count, perform: { _ in
            updateStats()
        })
        .onChange(of: unknownDoseEstimate) { newValue in
            updateStats()
        }
    }

    @State private var dosageStat: DosageStat?
    @State private var areThereUnknownDoses = false
    @State private var doAllIngestionsHaveSameUnitEqualToSubstance = true

    struct DoseInstance {
        let date: Date
        let dose: Double
    }

    private func updateStats() {
        doAllIngestionsHaveSameUnitEqualToSubstance = ingestions.wrappedValue.allSatisfy({ ing in
            ing.pureUnits == unit
        })
        areThereUnknownDoses = ingestions.wrappedValue.contains(where: { ing in
            ing.doseUnwrapped == nil
        })
        dosageStat = DosageStat(
            last30Days: getDayDosages(),
            last26Weeks: getWeekDosages(),
            last12Months: getMonthDosages(),
            years: getYearDosages())
    }

    private func getDayDosages() -> [DayDosage] {
        let last30Days = ingestions.wrappedValue.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: .now) <= 30
        }

        let doseInstances = convertToDoseInstances(ingestions: last30Days)

        let doseInstancesGroupedByDay = Dictionary(grouping: doseInstances) { instanceDose in
            let components = Calendar.current.dateComponents([.day, .month], from: instanceDose.date)
            if let day = components.day, let month = components.month {
                return String(day) + String(month)
            } else {
                return ""
            }
        }.values

        let dayDosages = doseInstancesGroupedByDay.compactMap { (doseInstances: [DoseInstance]) in
            if let summedUp = sumUpInstanceDosages(doseInstances: doseInstances) {
                return DayDosage(day: summedUp.date, dosage: summedUp.dose)
            } else {
                return nil
            }
        }
        return dayDosages
    }

    private func getWeekDosages() -> [WeekDosage] {
        let last26Weeks = ingestions.wrappedValue.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: .now) <= 26*7
        }

        let doseInstances = convertToDoseInstances(ingestions: last26Weeks)

        let doseInstancesGroupedByWeek = Dictionary(grouping: doseInstances) { instanceDose in
            let components = Calendar.current.dateComponents([.weekOfYear], from: instanceDose.date)
            if let weekOfYear = components.weekOfYear {
                return String(weekOfYear)
            } else {
                return ""
            }
        }.values

        let weekDosages = doseInstancesGroupedByWeek.compactMap { (doseInstances: [DoseInstance]) in
            if let summedUp = sumUpInstanceDosages(doseInstances: doseInstances) {
                return WeekDosage(week: summedUp.date, dosage: summedUp.dose)
            } else {
                return nil
            }
        }
        return weekDosages
    }

    private func getMonthDosages() -> [MonthDosage] {
        let last12Months = ingestions.wrappedValue.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: .now) <= 365
        }

        let instanceDosages = convertToDoseInstances(ingestions: last12Months)

        let doseInstancesGroupedByMonth = Dictionary(grouping: instanceDosages) { instanceDose in
            let components = Calendar.current.dateComponents([.month, .year], from: instanceDose.date)
            if let month = components.month, let year = components.year {
                return String(month) + String(year)
            } else {
                return ""
            }
        }

        let monthDosages = doseInstancesGroupedByMonth.values.compactMap { (doseInstances: [DoseInstance]) in
            if let summedUp = sumUpInstanceDosages(doseInstances: doseInstances) {
                return MonthDosage(month: summedUp.date, dosage: summedUp.dose)
            } else {
                return nil
            }
        }
        return monthDosages
    }

    private func getYearDosages() -> [YearDosage] {
        let doseInstances = convertToDoseInstances(ingestions: ingestions.wrappedValue)

        let doseInstancesGroupedByYear = Dictionary(grouping: doseInstances) { instanceDose in
            let components = Calendar.current.dateComponents([.year], from: instanceDose.date)
            if let year = components.year {
                return String(year)
            } else {
                return ""
            }
        }.values

        let yearDosages = doseInstancesGroupedByYear.compactMap { (doseInstances: [DoseInstance]) in
            if let summedUp = sumUpInstanceDosages(doseInstances: doseInstances) {
                return YearDosage(year: summedUp.date, dosage: summedUp.dose)
            } else {
                return nil
            }
        }
        return yearDosages
    }

    private func sumUpInstanceDosages(doseInstances: [DoseInstance]) -> DoseInstance? {
        let summedDosage = doseInstances.map({$0.dose}).reduce(0.0, +)
        if let date = doseInstances.first?.date, summedDosage > 0 {
            return DoseInstance(date: date, dose: summedDosage)
        } else {
            return nil
        }
    }

    private func convertToDoseInstances(ingestions: any Collection<Ingestion>) -> [DoseInstance] {
        return ingestions.map { ing in
            DoseInstance(date: ing.timeUnwrapped, dose: ing.pureSubstanceDose ?? unknownDoseEstimate)
        }
    }
}

#Preview {
    DosageStatScreen(substanceName: "MDMA")
}
