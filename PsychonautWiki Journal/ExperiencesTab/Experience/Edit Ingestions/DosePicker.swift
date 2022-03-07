import SwiftUI

struct DosePicker: View {

    let doseInfo: RoaDose?
    @Binding var doseMaybe: Double?
    @State private var doseText = ""
    @State private var dose: Double = 0

    var body: some View {
        VStack(alignment: .leading) {
            if let min = doseInfo?.thresholdUnwrapped ?? doseInfo?.light?.minUnwrapped,
               let max = doseInfo?.heavyUnwrapped ?? doseInfo?.strong?.maxUnwrapped,
               min < max {
                dynamicDoseRangeView
            } else {
                stackedDoseRangeView
            }
            doseTextFieldWithUnit
            if let min = doseInfo?.thresholdUnwrapped ?? doseInfo?.light?.minUnwrapped,
               let max = doseInfo?.heavyUnwrapped ?? doseInfo?.strong?.maxUnwrapped,
               min < max {
                getDoseSlider(min: min, max: max)
            }
        }
        .task {
            if let doseUnwrapped = doseMaybe {
                doseText = doseUnwrapped.cleanString
                dose = doseUnwrapped
            }
        }
        .padding(.vertical)
    }

    private func getDoseSlider(min: Double, max: Double) -> some View {
        let units = doseInfo?.units ?? ""
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
            maximumValueLabel: Text("\(max.cleanString) \(units)")) {
            Text("Dose")
        }
        .onChange(of: dose) { _ in
            let roundedDouble = dose.rounded(toPlaces: 5)
            doseText = roundedDouble.cleanString
            doseMaybe = roundedDouble
        }
    }

    private var doseTextFieldWithUnit: some View {
        HStack {
            TextField("Enter Dose", text: $doseText)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(doseInfo?.units ?? "")
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

    private var stackedDoseRangeView: some View {
        let units = doseInfo?.units ?? ""
        return VStack(alignment: .leading, spacing: 7) {
            if let thresh = doseInfo?.thresholdUnwrapped {
                Text("threshold (\(thresh.cleanString) \(units))")
            }
            if let lightMin = doseInfo?.light?.minUnwrapped,
               let lightMax = doseInfo?.light?.maxUnwrapped {
                Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
            }
            if let commonMin = doseInfo?.common?.minUnwrapped,
               let commonMax = doseInfo?.common?.maxUnwrapped {
                Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
            }
            if let strongMin = doseInfo?.strong?.minUnwrapped,
               let strongMax = doseInfo?.strong?.maxUnwrapped {
                Text("strong (\(strongMin.cleanString) - \(strongMax.cleanString) \(units))")
            }
            if let heavy = doseInfo?.heavyUnwrapped {
                Text("heavy (\(heavy.cleanString) \(units)+)")
            }
        }
    }

    private var dynamicDoseRangeView: some View {
        let units = doseInfo?.units ?? ""
        if let thresh = doseInfo?.thresholdUnwrapped,
           thresh >= dose {
            return Text("threshold (\(thresh.cleanString) \(units))")
        } else if let lightMin = doseInfo?.light?.minUnwrapped,
                  let lightMax = doseInfo?.light?.maxUnwrapped,
                  dose >= lightMin && dose <= lightMax {
            return Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
        } else if let commonMin = doseInfo?.common?.minUnwrapped,
                  let commonMax = doseInfo?.common?.maxUnwrapped,
                  dose >= commonMin && dose <= commonMax {
            return Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
        } else if let strongMin = doseInfo?.strong?.minUnwrapped,
                  let strongMax = doseInfo?.strong?.maxUnwrapped,
                  dose >= strongMin && dose <= strongMax {
            return Text("strong (\(strongMin.cleanString) - \(strongMax.cleanString) \(units))")
        } else if let heavy = doseInfo?.heavyUnwrapped,
                  dose >= heavy {
            return Text("heavy (\(heavy.cleanString) \(units)+)")
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
                doseInfo: substance.getDose(
                    for: substance.administrationRoutesUnwrapped.first!),
                doseMaybe: .constant(nil)
            )
        }
    }
}
