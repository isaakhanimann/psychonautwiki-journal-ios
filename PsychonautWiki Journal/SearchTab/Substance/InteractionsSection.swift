import SwiftUI

struct InteractionsSection: View {

    let substance: Substance

    var body: some View {
        if let interactions = substance.interactions {
            Section("Interactions") {
                let iconName = "exclamationmark.triangle"
                ForEach(interactions.dangerous, id: \.self) { name in
                    HStack(spacing: 0) {
                        Text(name)
                        Spacer()
                        Image(systemName: iconName)
                        Image(systemName: iconName)
                        Image(systemName: iconName)
                    }
                }.foregroundColor(InteractionType.dangerous.color)
                ForEach(interactions.unsafe, id: \.self) { name in
                    HStack(spacing: 0) {
                        Text(name)
                        Spacer()
                        Image(systemName: iconName)
                        Image(systemName: iconName)
                    }
                }.foregroundColor(InteractionType.unsafe.color)
                ForEach(interactions.uncertain, id: \.self) { name in
                    HStack(spacing: 0) {
                        Text(name)
                        Spacer()
                        Image(systemName: iconName)
                    }
                }.foregroundColor(InteractionType.uncertain.color)
            }
        }
    }
}

struct InteractionsSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                InteractionsSection(
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!
                )
            }
        }
    }
}

