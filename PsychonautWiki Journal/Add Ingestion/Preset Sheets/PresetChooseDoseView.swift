import SwiftUI

struct PresetChooseDoseView: View {

    let preset: Preset
    let dismiss: (AddResult) -> Void
    let experience: Experience?

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PresetChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        PresetChooseDoseView(
            preset: PreviewHelper.shared.preset,
            dismiss: { _ in },
            experience: nil
        )
    }
}
