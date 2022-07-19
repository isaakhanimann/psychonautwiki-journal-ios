import SwiftUI

struct DosePicker: View {

    let roaDose: RoaDose?
    @Binding var doseMaybe: Double?
    @Binding var selectedUnits: String?
    @State private var doseText = ""
    @State private var dose: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            let areUnitsDefined = roaDose?.unitsUnwrapped != nil
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
        if let thresh = roaDose?.thresholdUnwrapped,
           thresh >= dose {
            return Text("threshold (\(thresh.formatted()) \(units))")
                .foregroundColor(DoseRangeType.thresh.color)
        } else if let lightMin = roaDose?.light?.minUnwrapped,
                  let lightMax = roaDose?.light?.maxUnwrapped,
                  dose >= lightMin && dose <= lightMax {
            return Text("light (\(lightMin.formatted()) - \(lightMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.light.color)
        } else if let commonMin = roaDose?.common?.minUnwrapped,
                  let commonMax = roaDose?.common?.maxUnwrapped,
                  dose >= commonMin && dose <= commonMax {
            return Text("common (\(commonMin.formatted()) - \(commonMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.common.color)
        } else if let strongMin = roaDose?.strong?.minUnwrapped,
                  let strongMax = roaDose?.strong?.maxUnwrapped,
                  dose >= strongMin && dose <= strongMax {
            return Text("strong (\(strongMin.formatted()) - \(strongMax.formatted()) \(units))")
                .foregroundColor(DoseRangeType.strong.color)
        } else if let heavyOrStrongMax = roaDose?.heavyUnwrapped ?? roaDose?.strong?.maxUnwrapped,
                  dose >= heavyOrStrongMax {
            return Text("heavy (\(heavyOrStrongMax.formatted()) \(units)+)")
                .foregroundColor(DoseRangeType.heavy.color)
        } else {
            return Text(" ")
        }
    }
}

struct DosePicker_Previews: PreviewProvider {
    static var previews: some View {
        let substance = PreviewHelper.shared.getSubstance(with: "2-FA")!
        Form {
            DosePicker(
                roaDose: substance.getDose(
                    for: substance.administrationRoutesUnwrapped.first!),
                doseMaybe: .constant(nil),
                selectedUnits: .constant("mg")
            )
        }
    }
}
