import SwiftUI

struct PresetView: View {

    @ObservedObject var preset: Preset

    var body: some View {
        List {
            Section("Units") {
                Text(preset.unitsUnwrapped)
            }
            Section("1 \(preset.unitsUnwrapped) contains") {
                ForEach(preset.componentsUnwrapped) { com in
                    if let sub = com.substance {
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            HStack {
                                Text(com.substanceNameUnwrapped)
                                Spacer()
                                let dose = com.dosePerUnitOfPresetUnwrapped?.formatted() ?? "undefined"
                                Text("\(dose) \(com.unitsUnwrapped) \(com.administrationRoute ?? "")")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text(com.substanceNameUnwrapped)
                            Spacer()
                            let dose = com.dosePerUnitOfPresetUnwrapped?.formatted() ?? "undefined"
                            Text("\(dose) \(com.unitsUnwrapped) \(com.administrationRoute ?? "")")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(preset.nameUnwrapped)
    }
}

struct PresetView_Previews: PreviewProvider {
    static var previews: some View {
        PresetView(preset: PreviewHelper.shared.preset)
    }
}
