import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.dateForSorting > rhs.dateForSorting
    }

    var dateForSorting: Date {
        timeOfFirstIngestion ?? creationDateUnwrapped
    }

    var timeOfFirstIngestion: Date? {
        sortedIngestionsUnwrapped.first?.timeUnwrapped
    }

    var year: Int {
        Calendar.current.component(.year, from: dateForSorting)
    }

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var titleUnwrapped: String {
        title ?? creationDateUnwrappedString
    }

    var textUnwrapped: String {
        text ?? ""
    }

    var creationDateUnwrappedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: creationDateUnwrapped)
    }

    var sortedIngestionsUnwrapped: [Ingestion] {
        (ingestions?.allObjects as? [Ingestion] ?? []).sorted()
    }

    var sortedIngestionsToDraw: [Ingestion] {
        sortedIngestionsUnwrapped.filter { ing in
            ing.canTimeLineBeDrawn
        }
    }

    var ingestionColors: [Color] {
        var colors = [Color]()
        for ingestion in sortedIngestionsUnwrapped {
            colors.append(ingestion.swiftUIColorUnwrapped)
        }
        return colors
    }

    var distinctUsedSubstanceNames: [String] {
        sortedIngestionsUnwrapped.map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
    }

    class SubstanceWithDose: Identifiable {
        let substanceName: String
        let substance: Substance?
        let units: String?
        var cumulativeDose: Double

        // swiftlint:disable identifier_name
        var id: String {
            substanceName
        }

        init(substanceName: String, substance: Substance?, units: String?, cumulativeDose: Double) {
            self.substanceName = substanceName
            self.substance = substance
            self.units = units
            self.cumulativeDose = cumulativeDose
        }
    }

    var substancesWithDose: [SubstanceWithDose] {
        var result: [SubstanceWithDose] = []
        for ingestion in sortedIngestionsUnwrapped {
            if let firstSubDos = result.first(where: { subdos in
                subdos.substanceName == ingestion.substanceNameUnwrapped
            }) {
                if ingestion.dose == 0 {
                    firstSubDos.cumulativeDose = 0
                } else {
                    firstSubDos.cumulativeDose += ingestion.dose
                }
            } else {
                let newSubDos = SubstanceWithDose(
                    substanceName: ingestion.substanceNameUnwrapped,
                    substance: ingestion.substance,
                    units: ingestion.unitsUnwrapped,
                    cumulativeDose: ingestion.dose
                )
                result.append(newSubDos)
            }
        }
        return result
    }
}
