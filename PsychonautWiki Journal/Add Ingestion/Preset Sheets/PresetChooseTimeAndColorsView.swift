import SwiftUI

struct PresetChooseTimeAndColorsView: View {

    let preset: Preset
    let dose: Double
    let dismiss: (AddResult) -> Void
    let experience: Experience?

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PresetChooseTimeAndColorsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetChooseTimeAndColorsView(
            preset: PreviewHelper.shared.preset,
            dose: 1,
            dismiss: { _ in },
            experience: nil
        )
    }
}
