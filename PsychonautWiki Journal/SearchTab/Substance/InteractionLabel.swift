import SwiftUI

struct InteractionLabel: View {

    let text: String
    let interactionType: InteractionType

    enum InteractionType {
        case uncertain, unsafe, dangerous
    }

    var body: some View {
        switch interactionType {
        case .uncertain:
            Label(text, systemImage: "exclamationmark.triangle")
                .foregroundColor(Color.yellow)
        case .unsafe:
            Label(text, systemImage: "exclamationmark.triangle")
                .foregroundColor(Color.orange)
        case .dangerous:
            Label(text, systemImage: "xmark")
                .foregroundColor(Color.red)
        }
    }
}

struct InteractionLabel_Previews: PreviewProvider {
    static var previews: some View {
        InteractionLabel(text: "Alcohol", interactionType: .dangerous)
    }
}
