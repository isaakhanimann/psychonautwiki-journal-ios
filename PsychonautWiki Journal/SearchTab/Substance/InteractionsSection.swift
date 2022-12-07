import SwiftUI

struct InteractionsSection: View {

    let substance: Substance

    var body: some View {
        if let interactions = substance.interactions {
            Section("Interactions") {
                ForEach(interactions.dangerous, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        ForEach(0..<3) { _ in
                            Image(systemName: "exclamationmark.triangle")
                        }
                    }
                }.foregroundColor(InteractionType.dangerous.color)
                ForEach(interactions.unsafe, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        ForEach(0..<2) { _ in
                            Image(systemName: "exclamationmark.triangle")
                        }
                    }
                }.foregroundColor(InteractionType.unsafe.color)
                ForEach(interactions.uncertain, id: \.self) { name in
                    HStack {
                        Text(name)
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
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

