import SwiftUI

struct EditDoseRangeSection: View {

    let label: String
    let doseRange: DoseRange

    @State private var min: String
    @State private var max: String

    var body: some View {
        Section(header: Text(label)) {
            TextField("min", text: $min)
            TextField("max", text: $max)
        }
        .keyboardType(.decimalPad)
        .onChange(of: min) { _ in update() }
        .onChange(of: max) { _ in update() }
    }

    init(label: String, doseRange: DoseRange) {
        self.label = label
        self.doseRange = doseRange
        self._min = State(wrappedValue: doseRange.minUnwrapped?.cleanString ?? "")
        self._max = State(wrappedValue: doseRange.maxUnwrapped?.cleanString ?? "")
    }

    private func update() {
        doseRange.objectWillChange.send()
        if let minDouble = Double(min), let maxDouble = Double(max), minDouble <= maxDouble {
            doseRange.min = minDouble
            doseRange.max = maxDouble
        }
    }
}
