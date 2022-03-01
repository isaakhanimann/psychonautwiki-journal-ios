import SwiftUI

struct DosePicker: View {

    let roaDose: RoaDose?
    @Binding var doseMaybe: Double?

    @State private var doseDouble: Double = 0
    @State private var doseText = ""

    init(doseInfo: RoaDose?, doseMaybe: Binding<Double?>) {
        self.roaDose = doseInfo
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
            HStack {
                TextField("Enter Dose", text: $doseText)
                Text(roaDose?.units ?? "")
            }
            .onChange(of: doseText) { _ in
                doseText = doseText.trimmingCharacters(in: .whitespaces)
                if let doseUnwrapped = Double(doseText) {
                    doseDouble = doseUnwrapped
                    doseMaybe = doseUnwrapped
                } else {
                    doseMaybe = nil
                }
            }
            doseRangeView
                .foregroundColor(.secondary)

        }
    }

    private var doseRangeView: some View {
        let units = roaDose?.units ?? ""

        if let thresh = roaDose?.thresholdUnwrapped,
           thresh >= doseDouble {
            return Text("threshold (\(thresh.cleanString) \(units))")
        } else if let lightMin = roaDose?.light?.minUnwrapped,
                  let lightMax = roaDose?.light?.maxUnwrapped,
                  doseDouble >= lightMin && doseDouble <= lightMax {
            return Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
        } else if let commonMin = roaDose?.common?.minUnwrapped,
                  let commonMax = roaDose?.common?.maxUnwrapped,
                  doseDouble >= commonMin && doseDouble <= commonMax {
            return Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
        } else if let strongMin = roaDose?.strong?.minUnwrapped,
                  let strongMax = roaDose?.strong?.maxUnwrapped,
                  doseDouble >= strongMin && doseDouble <= strongMax {
            return Text("strong (\(strongMin.cleanString) - \(strongMax.cleanString) \(units))")
        } else if let heavy = roaDose?.heavyUnwrapped,
                  doseDouble >= heavy {
            return Text("heavy (\(heavy.cleanString) \(units)+)")
        } else {
            return Text(" ")
        }
    }
}

struct DosePicker_Previews: PreviewProvider {
    static var previews: some View {
        let substance = PreviewHelper().substancesFile.psychoactiveClassesUnwrapped[0].substancesUnwrapped[2]

        DosePicker(
            doseInfo: substance.getDose(
                for: substance.administrationRoutesUnwrapped.first!),
            doseMaybe: .constant(nil)
        )
    }
}
