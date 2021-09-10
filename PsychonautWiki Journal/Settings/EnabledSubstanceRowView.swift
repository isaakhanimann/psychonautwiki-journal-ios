import SwiftUI

struct EnabledSubstanceRowView: View {

    @ObservedObject var substance: Substance
    let updateAllToggle: () -> Void

    var body: some View {
        let toggleBinding = Binding<Bool>(
            get: {self.substance.isEnabled},
            set: {
                self.substance.isEnabled = $0
                updateAllToggle()
            }
        )
        Toggle(substance.nameUnwrapped, isOn: toggleBinding)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    }
}

struct EnabledSubstanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        EnabledSubstanceRowView(substance: helper.substance, updateAllToggle: {})
    }
}
