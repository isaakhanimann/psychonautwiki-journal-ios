import SwiftUI

struct DosePicker: View {

    let doseInfo: RoaDose?
    @Binding var doseMaybe: Double?

    @State private var doseDouble: Double = 0
    @State private var doseText = ""

    init(doseInfo: RoaDose?, doseMaybe: Binding<Double?>) {
        self.doseInfo = doseInfo
        self._doseMaybe = doseMaybe

        if let doseUnwrapped = doseMaybe.wrappedValue {
            self._doseDouble = State(wrappedValue: doseUnwrapped)
            self._doseText = State(wrappedValue: doseUnwrapped.cleanString)
        } else {
            self._doseDouble = State(wrappedValue: doseInfo?.threshold ?? 0)
        }
    }

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
        .padding(.vertical)
    }

    private func getDoseSlider(min: Double, max: Double) -> some View {
        let units = doseInfo?.units ?? ""
        let difference = max - min
        let stepCandidates = [0.1, 0.25, 0.5, 1.0, 5.0, 10.0]
        let approximateStepSize = difference/20

        let closestStep = stepCandidates.min(by: { abs($0 - approximateStepSize) < abs($1 - approximateStepSize)})!

        let sliderMin = floor(min/closestStep) * closestStep
        let sliderMax = ceil(max/closestStep) * closestStep

        return Slider(
            value: $doseDouble.animation(),
            in: sliderMin...sliderMax,
            step: closestStep,
            minimumValueLabel: Text("\(min.cleanString) \(units)"),
            maximumValueLabel: Text("\(max.cleanString) \(units)")) {
            Text("Dose")
        }
        .onChange(of: doseDouble) { _ in
            let roundedDouble = doseDouble.rounded(toPlaces: 5)
            doseText = roundedDouble.cleanString
            doseMaybe = doseDouble
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
                doseDouble = doseUnwrapped
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
           thresh >= doseDouble {
            return Text("threshold (\(thresh.cleanString) \(units))")
        } else if let lightMin = doseInfo?.light?.minUnwrapped,
                  let lightMax = doseInfo?.light?.maxUnwrapped,
                  doseDouble >= lightMin && doseDouble <= lightMax {
            return Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
        } else if let commonMin = doseInfo?.common?.minUnwrapped,
                  let commonMax = doseInfo?.common?.maxUnwrapped,
                  doseDouble >= commonMin && doseDouble <= commonMax {
            return Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
        } else if let strongMin = doseInfo?.strong?.minUnwrapped,
                  let strongMax = doseInfo?.strong?.maxUnwrapped,
                  doseDouble >= strongMin && doseDouble <= strongMax {
            return Text("strong (\(strongMin.cleanString) - \(strongMax.cleanString) \(units))")
        } else if let heavy = doseInfo?.heavyUnwrapped,
                  doseDouble >= heavy {
            return Text("heavy (\(heavy.cleanString) \(units)+)")
        } else {
            return Text(" ")
        }
    }
}

struct DosePicker_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        let substance = helper.substancesFile.psychoactiveClassesUnwrapped[0].substancesUnwrapped[2]

        Form {
            DosePicker(
                doseInfo: substance.getDose(
                    for: substance.administrationRoutesUnwrapped.first!),
                doseMaybe: .constant(nil)
            )
        }
    }
}
