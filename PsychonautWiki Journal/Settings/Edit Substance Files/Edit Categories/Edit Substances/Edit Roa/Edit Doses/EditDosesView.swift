import SwiftUI
import CoreData

struct EditDosesView: View {

    @ObservedObject var doseTypes: DoseTypes

    @Environment(\.managedObjectContext) var moc

    @State private var units: String
    @State private var threshold: String
    @State private var heavy: String
    @State private var isKeyboardShowing = false
    @State private var unitSelection = UnitTypes.custom

    var body: some View {
        Form {
            Section(header: Text("units")) {
                Picker("units", selection: $unitSelection) {
                    ForEach(UnitTypes.allCases, id: \.self) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
                .onChange(of: unitSelection, perform: { value in
                    if value != .custom {
                        units = value.rawValue
                    }
                })
                if unitSelection == .custom {
                    TextField("e.g. mg", text: $units)
                        .autocapitalization(.none)
                }
            }
            Section(header: Text("threshold")) {
                TextField("min", text: $threshold)
                    .keyboardType(.decimalPad)
            }
            EditDoseRangeSection(label: "light", doseRange: doseTypes.light!)
            EditDoseRangeSection(label: "common", doseRange: doseTypes.common!)
            EditDoseRangeSection(label: "strong", doseRange: doseTypes.strong!)
            Section(header: Text("heavy")) {
                TextField("min", text: $heavy)
                    .keyboardType(.decimalPad)
            }
        }
        .onChange(of: units) { _ in update() }
        .onChange(of: threshold) { _ in update() }
        .onChange(of: heavy) { _ in update() }
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
        .navigationTitle("Edit Dose Info")
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardShowing = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                isKeyboardShowing = false
            }
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button {
                        hideKeyboard()
                        if moc.hasChanges {
                            try? moc.save()
                        }
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
    }

    init(doseTypes: DoseTypes) {
        self.doseTypes = doseTypes
        self._units = State(wrappedValue: doseTypes.units ?? "")
        if let unitSelection = UnitTypes(rawValue: doseTypes.units ?? "") {
            self._unitSelection = State(wrappedValue: unitSelection)
        }
        self._threshold = State(wrappedValue: doseTypes.thresholdUnwrapped?.cleanString ?? "")
        self._heavy = State(wrappedValue: doseTypes.heavyUnwrapped?.cleanString ?? "")
    }

    // swiftlint:disable identifier_name
    enum UnitTypes: String, CaseIterable {
        case µg
        case mg
        case g
        case ml
        case custom
    }

    private func update() {
        doseTypes.substanceRoa?.objectWillChange.send()
        doseTypes.units = units
        if let thresholdDouble = Double(threshold) {
            doseTypes.threshold = thresholdDouble
        }
        if let heavyDouble = Double(heavy) {
            doseTypes.heavy = heavyDouble
        }
    }

    // swiftlint:disable function_parameter_count
    static func getDoseTypes(
        moc: NSManagedObjectContext,
        units: String,
        threshold: String,
        lightMin: String,
        lightMax: String,
        commonMin: String,
        commonMax: String,
        strongMin: String,
        strongMax: String,
        heavy: String
    ) -> DoseTypes {
        let thresholdDouble = Double(threshold)
        let lightMinDouble = Double(lightMin)
        let lightMaxDouble = Double(lightMax)
        let commonMinDouble = Double(commonMin)
        let commonMaxDouble = Double(commonMax)
        let strongMinDouble = Double(strongMin)
        let strongMaxDouble = Double(strongMax)
        let heavyDouble = Double(heavy)

        let doseTypes = DoseTypes(context: moc)
        doseTypes.units = units

        if let thresholdUnwrapped = thresholdDouble {
            doseTypes.threshold = thresholdUnwrapped
        }

        if let lightMinUnwrapped = lightMinDouble, let lightMaxUnwrapped = lightMaxDouble {
            let lightDoseRange = DoseRange(context: moc)
            lightDoseRange.min = lightMinUnwrapped
            lightDoseRange.max = lightMaxUnwrapped
            doseTypes.light = lightDoseRange
        }

        if let commonMinUnwrapped = commonMinDouble, let commonMaxUnwrapped = commonMaxDouble {
            let commonDoseRange = DoseRange(context: moc)
            commonDoseRange.min = commonMinUnwrapped
            commonDoseRange.max = commonMaxUnwrapped
            doseTypes.common = commonDoseRange
        }

        if let strongMinUnwrapped = strongMinDouble, let strongMaxUnwrapped = strongMaxDouble {
            let strongDoseRange = DoseRange(context: moc)
            strongDoseRange.min = strongMinUnwrapped
            strongDoseRange.max = strongMaxUnwrapped
            doseTypes.strong = strongDoseRange
        }

        if let heavyUnwrapped = heavyDouble {
            doseTypes.heavy = heavyUnwrapped
        }

        return doseTypes
    }
}
