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
            }
            if areUnitsDefined {
                dynamicDoseRangeView
            }
            doseTextFieldWithUnit
            if let min = roaDose?.thresholdUnwrapped ?? roaDose?.light?.minUnwrapped,
               let max = roaDose?.heavyUnwrapped ?? roaDose?.strong?.maxUnwrapped,
               min < max, areUnitsDefined {
                getDoseSlider(min: min, max: max)
            }
        }
        .task {
            if let doseUnwrapped = doseMaybe {
                doseText = doseUnwrapped.cleanString
                dose = doseUnwrapped
            }
        }
    }

    private func getDoseSlider(min: Double, max: Double) -> some View {
        let units = roaDose?.units ?? ""
        let difference = max - min
        let stepCandidates = [0.05, 0.1, 0.2, 0.25, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500]
        let approximateStepSize = difference/20
        let closestStep = stepCandidates.min(by: { abs($0 - approximateStepSize) < abs($1 - approximateStepSize)})!
        let sliderMin = floor(min/closestStep) * closestStep
        let sliderMax = ceil(max/closestStep) * closestStep
        return Slider(
            value: $dose.animation(),
            in: sliderMin...sliderMax,
            step: closestStep,
            minimumValueLabel: Text("\(min.cleanString) \(units)"),
            maximumValueLabel: Text("\(max.cleanString) \(units)")
        ) {
            Text("Dose")
        }
        .onChange(of: dose) { _ in
            let roundedDouble = dose.rounded(toPlaces: 5)
            doseText = roundedDouble.cleanString
            doseMaybe = roundedDouble
        }
    }

    private enum RangeType {
        case thresh, light, common, strong, heavy
    }

    private var currentRange: RangeType? {
        if let thresh = roaDose?.thresholdUnwrapped,
           thresh >= dose {
            return .thresh
        } else if let lightMin = roaDose?.light?.minUnwrapped,
                  let lightMax = roaDose?.light?.maxUnwrapped,
                  dose >= lightMin && dose <= lightMax {
            return .light
        } else if let commonMin = roaDose?.common?.minUnwrapped,
                  let commonMax = roaDose?.common?.maxUnwrapped,
                  dose >= commonMin && dose <= commonMax {
            return .common
        } else if let strongMin = roaDose?.strong?.minUnwrapped,
                  let strongMax = roaDose?.strong?.maxUnwrapped,
                  dose >= strongMin && dose <= strongMax {
            return .strong
        } else if let heavyOrStrongMax = roaDose?.heavyUnwrapped ?? roaDose?.strong?.maxUnwrapped,
                  dose >= heavyOrStrongMax {
            return .heavy
        } else {
            return nil
        }
    }

    var doseColor: Color {
        guard let currentRange = currentRange else {
            return .primary
        }
        switch currentRange {
        case .thresh:
            return DoseView.threshColor
        case .light:
            return DoseView.lightColor
        case .common:
            return DoseView.commonColor
        case .strong:
            return DoseView.strongColor
        case .heavy:
            return DoseView.heavyColor
        }
    }

    private var doseTextFieldWithUnit: some View {
        HStack {
            TextField("Enter Dose", text: $doseText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(roaDose?.units != nil ? doseColor : .primary)
            Text(selectedUnits ?? "")
        }
        .font(.title)
        .onChange(of: doseText) { _ in
            if let doseUnwrapped = Double(doseText) {
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
            return Text("threshold (\(thresh.cleanString) \(units))")
                .foregroundColor(DoseView.threshColor)
        } else if let lightMin = roaDose?.light?.minUnwrapped,
                  let lightMax = roaDose?.light?.maxUnwrapped,
                  dose >= lightMin && dose <= lightMax {
            return Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
                .foregroundColor(DoseView.lightColor)
        } else if let commonMin = roaDose?.common?.minUnwrapped,
                  let commonMax = roaDose?.common?.maxUnwrapped,
                  dose >= commonMin && dose <= commonMax {
            return Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
                .foregroundColor(DoseView.commonColor)
        } else if let strongMin = roaDose?.strong?.minUnwrapped,
                  let strongMax = roaDose?.strong?.maxUnwrapped,
                  dose >= strongMin && dose <= strongMax {
            return Text("strong (\(strongMin.cleanString) - \(strongMax.cleanString) \(units))")
                .foregroundColor(DoseView.strongColor)
        } else if let heavyOrStrongMax = roaDose?.heavyUnwrapped ?? roaDose?.strong?.maxUnwrapped,
                  dose >= heavyOrStrongMax {
            return Text("heavy (\(heavyOrStrongMax.cleanString) \(units)+)")
                .foregroundColor(DoseView.heavyColor)
        } else {
            return Text(" ")
        }
    }
}

struct DosePicker_Previews: PreviewProvider {
    static var previews: some View {
        let substance = PreviewHelper.shared.substancesFile.psychoactiveClassesUnwrapped[0].substancesUnwrapped[2]

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
