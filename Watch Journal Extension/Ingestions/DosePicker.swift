import SwiftUI

struct DosePicker: View {

    let doseInfo: DoseTypes?
    @Binding var doseMaybe: Double?

    @State private var doseDouble: Double = 0
    @State private var doseText = ""

    init(doseInfo: DoseTypes?, doseMaybe: Binding<Double?>) {
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
            HStack {
                TextField("Enter Dose", text: $doseText)
                Text(doseInfo?.units ?? "")
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
        let units = doseInfo?.units ?? ""

        if let thresh = doseInfo?.thresholdUnwrapped,
           thresh >= doseDouble {
            return Text("threshold (\(thresh.cleanString) \(units))")
        } else if let lightMin = doseInfo?.lightUnwrapped?.minUnwrapped,
                  let lightMax = doseInfo?.lightUnwrapped?.maxUnwrapped,
                  doseDouble >= lightMin && doseDouble <= lightMax {
            return Text("light (\(lightMin.cleanString) - \(lightMax.cleanString) \(units))")
        } else if let commonMin = doseInfo?.commonUnwrapped?.minUnwrapped,
                  let commonMax = doseInfo?.commonUnwrapped?.maxUnwrapped,
                  doseDouble >= commonMin && doseDouble <= commonMax {
            return Text("common (\(commonMin.cleanString) - \(commonMax.cleanString) \(units))")
        } else if let strongMin = doseInfo?.strongUnwrapped?.minUnwrapped,
                  let strongMax = doseInfo?.strongUnwrapped?.maxUnwrapped,
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
        let helper = PersistenceController.preview.createPreviewHelper()
        let substance = helper.substancesFile.allSubstancesUnwrapped[2]

        DosePicker(
            doseInfo: substance.getDose(
                for: substance.administrationRoutesUnwrapped.first!),
            doseMaybe: .constant(nil)
        )
    }
}
