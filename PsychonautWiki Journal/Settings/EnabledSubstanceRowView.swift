import SwiftUI

struct EnabledSubstanceRowView: View {

    @ObservedObject var substance: Substance

    var body: some View {
        Toggle(substance.nameUnwrapped, isOn: $substance.isEnabled)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    }
}

struct EnabledSubstanceRowView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        EnabledSubstanceRowView(substance: helper.substance)
    }
}
