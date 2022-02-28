import SwiftUI

struct SubstanceView: View {

    let substance: Substance

    var body: some View {
        NavigationView {
            List {
                ForEach(substance.roasUnwrapped) { roa in
                    Section(roa.nameUnwrapped.rawValue) {
                        DoseView(roaDose: roa.dose)
                        DurationView(duration: roa.duration)
                    }
                }
            }
            .navigationTitle(substance.nameUnwrapped)
        }
    }
}

struct SubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        SubstanceView(substance: PreviewHelper().getSubstance(with: "Caffeine")!)
    }
}
