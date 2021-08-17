import SwiftUI

struct InteractionRowView: View {

    @ObservedObject var interaction: GeneralInteraction

    var body: some View {
        HStack {
            Text(interaction.nameUnwrapped)
            Spacer()
            Button {
                interaction.isEnabled.toggle()
            } label: {
                if interaction.isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        }
    }
}
