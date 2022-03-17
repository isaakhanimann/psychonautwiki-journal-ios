import SwiftUI

struct DoseConversionSectionView: View {

    let presetComponent: PresetComponent
    @Binding var presetDose: Double

    var body: some View {
        Section("\(presetComponent.substanceNameUnwrapped) Conversion") {
            let roaDose = presetComponent.substance?.getDose(for: presetComponent.administrationRouteUnwrapped)
            DoseView(roaDose: roaDose)
            if let dosePerUnit = presetComponent.dosePerUnitOfPresetUnwrapped {
                let comDose = dosePerUnit * presetDose
                let doseText = comDose.formatted()
                HStack(alignment: .firstTextBaseline) {
                    let type = roaDose?.getRangeType(for: comDose, with: presetComponent.unitsUnwrapped) ?? .none
                    Text("\(doseText) \(presetComponent.unitsUnwrapped) ")
                        .foregroundColor(type.color)
                        .font(.title)
                    Spacer()
                    Text(presetComponent.administrationRouteUnwrapped?.rawValue ?? "")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct DoseConversionSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DoseConversionSectionView(
                presetComponent: PreviewHelper.shared.preset.componentsUnwrapped.first!,
                presetDose: .constant(1.0)
            )
        }
    }
}
