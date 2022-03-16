import SwiftUI

struct InteractionLabel: View {

    let text: String
    let interactionType: InteractionType

    var body: some View {
        Label(text, systemImage: interactionType.systemImageName)
            .foregroundColor(interactionType.color)
    }
}

struct InteractionLabel_Previews: PreviewProvider {
    static var previews: some View {
        InteractionLabel(text: "Alcohol", interactionType: .dangerous)
    }
}
