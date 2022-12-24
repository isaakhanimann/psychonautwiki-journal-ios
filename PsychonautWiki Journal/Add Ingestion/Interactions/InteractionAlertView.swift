import SwiftUI

struct InteractionAlertView: View {

    let interactions: [Interaction]
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            title
            textBody
            Button("Cancel") {
                isShowing = false
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(.ultraThickMaterial)
        .cornerRadius(15)
        .clipped()
        .padding(.horizontal, 20)
    }

    var iconColor: Color {
        if interactions.contains(where: { int in
            int.interactionType == .dangerous
        }) {
            return InteractionType.dangerous.color
        } else if interactions.contains(where: { int in
            int.interactionType == .unsafe
        }) {
            return InteractionType.unsafe.color
        } else {
            return InteractionType.uncertain.color
        }
    }

    var title: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(iconColor)
            Text("Interaction Detected")
                .font(.title.bold())
        }
    }

    var textBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(interactions) { interaction in
                getAlertText(for: interaction)
            }
        }
    }

    func getAlertText(for interaction: Interaction) -> Text {
        var result = Text("")
        switch interaction.interactionType {
        case .uncertain:
            result = Text("**Uncertain Interaction**")
        case .unsafe:
            result = Text("**Unsafe Interaction**")
        case .dangerous:
            result = Text("**Dangerous Interaction**")
        }
        result = result + Text(" between **\(interaction.aName) and \(interaction.bName)**")
        return result
    }
}

struct InteractionAlertView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionAlertView(
            interactions: [Interaction(aName: "Tramadol", bName: "Alcohol", interactionType: .dangerous)],
            isShowing: .constant(true))
    }
}
