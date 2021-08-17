import SwiftUI

struct EditDurationRangeSection: View {

    let label: String
    @ObservedObject var durationRange: DurationRange

    @State private var min: String
    @State private var max: String
    @State private var units: DurationUnits

    var body: some View {
        Section(header: Text(label)) {
            TextField("min", text: $min)
            TextField("max", text: $max)
            Picker("units", selection: $units) {
                ForEach(DurationUnits.allCases, id: \.rawValue) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
        }
        .keyboardType(.decimalPad)
        .onChange(of: min) { _ in update() }
        .onChange(of: max) { _ in update() }
        .onChange(of: units) { _ in update() }
    }

    init(label: String, durationRange: DurationRange) {
        self.label = label
        self.durationRange = durationRange
        let range = EditDurationRangeSection.getTimeAndUnits(for: durationRange)
        self._min = State(wrappedValue: range.min)
        self._max = State(wrappedValue: range.max)
        self._units = State(wrappedValue: range.units)
    }

    func update() {
        durationRange.objectWillChange.send()
        if let minMaxUnwrapped = EditDurationRangeSection.getValidMinMax(from: min, and: max, and: units) {
            durationRange.minSec = minMaxUnwrapped.minSec
            durationRange.maxSec = minMaxUnwrapped.maxSec
        }
    }

    static func getValidMinMax(
        from min: String, and max: String,
        and durationUnits: DurationUnits
    ) -> (minSec: Double, maxSec: Double)? {
        guard let minDouble = Double(min) else {
            return nil
        }
        guard let maxDouble = Double(max) else {
            return nil
        }
        guard minDouble <= maxDouble else {
            return nil
        }

        let minSec = getSec(double: minDouble, units: durationUnits)
        let maxSec = getSec(double: maxDouble, units: durationUnits)

        return (minSec, maxSec)
    }

    private static func getSec(double: Double, units: DurationUnits) -> TimeInterval {
        switch units {
        case .seconds:
            return double
        case .minutes:
            return 60 * double
        case .hours:
            return 60 * 60 * double
        case .days:
            return 60 * 60 * 24 * double
        }
    }

    // swiftlint:disable large_tuple
    private static func getTimeAndUnits(for durationRange: DurationRange)
    -> (
        min: String,
        max: String,
        units: DurationUnits
    ) {
        let minInSec = durationRange.minSec
        let maxInSec = durationRange.maxSec
        if minInSec / 60 < 1 {
            return (minInSec.cleanString, maxInSec.cleanString, .seconds)
        } else if minInSec / 3600 < 1 {
            return ((minInSec/60).cleanString, (maxInSec/60).cleanString, .minutes)
        } else if minInSec / (24 * 3600) < 1 {
            return ((minInSec/3600).cleanString, (maxInSec/3600).cleanString, .hours)
        } else {
            return ((minInSec/(24 * 3600)).cleanString, (maxInSec/(24 * 3600)).cleanString, .days)
        }
    }

    enum DurationUnits: String, CaseIterable {
            case seconds, minutes, hours, days
    }

}
