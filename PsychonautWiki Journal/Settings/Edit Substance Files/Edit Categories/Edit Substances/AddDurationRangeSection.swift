import SwiftUI

struct AddDurationRangeSection: View {

    let label: String
    @Binding var min: String
    @Binding var max: String
    @Binding var units: EditDurationRangeSection.DurationUnits

    var body: some View {
        Section(header: Text(label)) {
            TextField("min", text: $min)
            TextField("max", text: $max)
            Picker("units", selection: $units) {
                ForEach(EditDurationRangeSection.DurationUnits.allCases, id: \.rawValue) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
        }
        .keyboardType(.decimalPad)
    }
}
