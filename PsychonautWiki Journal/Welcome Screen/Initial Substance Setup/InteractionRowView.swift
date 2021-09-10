import SwiftUI

struct InteractionRowView: View {

    @ObservedObject var interaction: GeneralInteraction

    var body: some View {
        Toggle(interaction.nameUnwrapped, isOn: $interaction.isEnabled)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    }
}
