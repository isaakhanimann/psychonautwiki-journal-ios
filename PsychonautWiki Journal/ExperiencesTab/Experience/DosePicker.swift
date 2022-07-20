import SwiftUI

struct DosePicker: View {

    let roaDose: RoaDose?
    @Binding var doseMaybe: Double?
    @Binding var selectedUnits: String?
    @State private var doseText = ""
    @State private var dose: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            let areUnitsDefined = roaDose?.units != nil
            if !areUnitsDefined {
                UnitsPicker(units: $selectedUnits)
                    .padding(.bottom, 10)
            }
            if areUnitsDefined {
                dynamicDoseRangeView
            }
            doseTextFieldWithUnit
        }
        .task {
            if let doseUnwrapped = doseMaybe {
                doseText = doseUnwrapped.formatted()
                dose = doseUnwrapped
            }
        }
    }

    var doseType: DoseRangeType {
        guard let selectedUnits = selectedUnits else {
            return .none
        }
        return roaDose?.getRangeType(for: dose, with: selectedUnits) ?? .none
    }

    private var doseTextFieldWithUnit: some View {
        HStack {
            TextField("Enter Dose", text: $doseText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(doseType.color)
            Text(selectedUnits ?? "")
        }
        .font(.title)
        .onChange(of: doseText) { _ in
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .decimal
            if let doseUnwrapped = formatter.number(from: doseText)?.doubleValue {
                dose = doseUnwrapped
                doseMaybe = doseUnwrapped
            } else {
                doseMaybe = nil
            }
        }
    }

    private var dynamicDoseRangeView: some View {
        let units = roaDose?.units ?? ""
        if let thresh = roaDose?.threshold,
           thresh >= dose {
            return Text("threshold (\(thresh.formatted()) \(units))")
                .foregroundColor(DoseRangeType.thresh.color)
        } else if let lightMin = roaDose?.light?.min,
                  let lightMax = roaDose?.light?.max,
                  dose >= lightMin && dose <= lightMax {
            return Text("light (\(lightMin.formatted()) - \(lightMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.light.color)
        } else if let commonMin = roaDose?.common?.min,
                  let commonMax = roaDose?.common?.max,
                  dose >= commonMin && dose <= commonMax {
            return Text("common (\(commonMin.formatted()) - \(commonMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.common.color)
        } else if let strongMin = roaDose?.strong?.min,
                  let strongMax = roaDose?.strong?.max,
                  dose >= strongMin && dose <= strongMax {
            return Text("strong (\(strongMin.formatted()) - \(strongMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.strong.color)
        } else if let heavyOrStrongMax = roaDose?.heavy ?? roaDose?.strong?.max,
                  dose >= heavyOrStrongMax {
            return Text("heavy (\(heavyOrStrongMax.formatted()) \(units)+)")
                .foregroundColor(DoseRangeType.heavy.color)
        } else {
            return Text(" ")
        }
    }
}
