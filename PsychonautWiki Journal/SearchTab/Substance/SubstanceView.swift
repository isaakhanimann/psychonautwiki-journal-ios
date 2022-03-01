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
                        if let bio = roa.bioavailability?.displayString {
                            HStack {
                                Text("Bioavailability ")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(bio)%")

                            }
                        }
                    }
                }
            }
            .navigationTitle(substance.nameUnwrapped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let url = substance.url {
                        Link("Article", destination: url)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ingest", action: ingest)
                }
            }
        }
    }

    private func ingest() {

    }
}

struct SubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        SubstanceView(substance: PreviewHelper().getSubstance(with: "Galantamine")!)
    }
}
