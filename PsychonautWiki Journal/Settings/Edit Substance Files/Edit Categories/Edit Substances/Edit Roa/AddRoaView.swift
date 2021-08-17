import SwiftUI

struct AddRoaView: View {

    @ObservedObject var substance: Substance

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc

    @State private var name = Roa.AdministrationRoute.oral

    @State private var onsetMin = ""
    @State private var onsetMax = ""
    @State private var onsetUnits = EditDurationRangeSection.DurationUnits.minutes

    @State private var comeupMin = ""
    @State private var comeupMax = ""
    @State private var comeupUnits = EditDurationRangeSection.DurationUnits.minutes

    @State private var peakMin = ""
    @State private var peakMax = ""
    @State private var peakUnits = EditDurationRangeSection.DurationUnits.minutes

    @State private var offsetMin = ""
    @State private var offsetMax = ""
    @State private var offsetUnits = EditDurationRangeSection.DurationUnits.minutes

    @State private var isShowingOnsetAlert = false
    @State private var isShowingComeupAlert = false
    @State private var isShowingPeakAlert = false
    @State private var isShowingOffsetAlert = false

    var body: some View {
        NavigationView {
            Form {
                Picker("Route", selection: $name) {
                    ForEach(Roa.AdministrationRoute.allCases, id: \.rawValue) { route in
                        Text(route.displayString).tag(route)
                    }
                }

                AddDurationRangeSection(
                    label: "onset",
                    min: $onsetMin,
                    max: $onsetMax,
                    units: $onsetUnits
                )
                .alert(isPresented: $isShowingOnsetAlert) {
                    Alert(
                        title: Text("Onset Invalid"),
                        message: Text("You must define a valid onset duration range"),
                        dismissButton: .default(Text("Ok"))
                    )
                }

                AddDurationRangeSection(
                    label: "comeup",
                    min: $comeupMin,
                    max: $comeupMax,
                    units: $comeupUnits
                )
                .alert(isPresented: $isShowingComeupAlert) {
                    Alert(
                        title: Text("Comeup Invalid"),
                        message: Text("You must define a valid comeup duration range"),
                        dismissButton: .default(Text("Ok"))
                    )
                }

                AddDurationRangeSection(
                    label: "peak",
                    min: $peakMin,
                    max: $peakMax,
                    units: $peakUnits
                )
                .alert(isPresented: $isShowingPeakAlert) {
                    Alert(
                        title: Text("Peak Invalid"),
                        message: Text("You must define a valid peak duration range"),
                        dismissButton: .default(Text("Ok"))
                    )
                }

                AddDurationRangeSection(
                    label: "offset",
                    min: $offsetMin,
                    max: $offsetMax,
                    units: $offsetUnits
                )
                .alert(isPresented: $isShowingOffsetAlert) {
                    Alert(
                        title: Text("Offset Invalid"),
                        message: Text("You must define a valid offset duration range"),
                        dismissButton: .default(Text("Ok"))
                    )
                }
            }
            .navigationTitle("Add Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button("Add", action: addRoaMaybe)
                }
            }
        }
        .currentDeviceNavigationViewStyle()
    }

    private func addRoaMaybe() {
        guard let onsetMinMaxUnwrapped = EditDurationRangeSection.getValidMinMax(
                from: onsetMin,
                and: onsetMax,
                and: onsetUnits
        ) else {
            isShowingOnsetAlert.toggle()
            return
        }

        guard let comeupMinMaxUnwrapped = EditDurationRangeSection.getValidMinMax(
                from: comeupMin,
                and: comeupMax,
                and: comeupUnits
        ) else {
            isShowingComeupAlert.toggle()
            return
        }

        guard let peakMinMaxUnwrapped = EditDurationRangeSection.getValidMinMax(
                from: peakMin,
                and: peakMax,
                and: peakUnits
        ) else {
            isShowingPeakAlert.toggle()
            return
        }

        guard let offsetMinMaxUnwrapped = EditDurationRangeSection.getValidMinMax(
                from: offsetMin,
                and: offsetMax,
                and: offsetUnits
        ) else {
            isShowingOffsetAlert.toggle()
            return
        }

        addRoa(
            onset: onsetMinMaxUnwrapped,
            comeup: comeupMinMaxUnwrapped,
            peak: peakMinMaxUnwrapped,
            offset: offsetMinMaxUnwrapped
        )

    }

    private func addRoa(
        onset: (minSec: Double, maxSec: Double),
        comeup: (minSec: Double, maxSec: Double),
        peak: (minSec: Double, maxSec: Double),
        offset: (minSec: Double, maxSec: Double)
    ) {
        moc.performAndWait {
            let newRoa = Roa(context: moc)
            newRoa.name = name.rawValue

            let newDurations = DurationTypes(context: moc)
            let newOnset = DurationRange(context: moc)
            newOnset.minSec = onset.minSec
            newOnset.maxSec = onset.maxSec
            newDurations.onset = newOnset
            let newComeup = DurationRange(context: moc)
            newComeup.minSec = comeup.minSec
            newComeup.maxSec = comeup.maxSec
            newDurations.comeup = newComeup
            let newPeak = DurationRange(context: moc)
            newPeak.minSec = peak.minSec
            newPeak.maxSec = peak.maxSec
            newDurations.peak = newPeak
            let newOffset = DurationRange(context: moc)
            newOffset.minSec = offset.minSec
            newOffset.maxSec = offset.maxSec
            newDurations.offset = newOffset

            newRoa.durationTypes = newDurations

            newRoa.doseTypes = DoseTypes.createDefault(moc: moc)
            newRoa.substance = substance
            if moc.hasChanges {
                try? moc.save()
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}
