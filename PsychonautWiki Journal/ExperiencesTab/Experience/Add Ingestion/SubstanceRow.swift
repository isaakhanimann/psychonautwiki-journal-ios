import SwiftUI

struct SubstanceRow: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience

    var body: some View {
        if let route = substance.administrationRoutesUnwrapped.first,
           substance.administrationRoutesUnwrapped.count == 1 {
            NavigationLink(
                destination: ChooseDoseView(
                    substance: substance,
                    administrationRoute: route,
                    dismiss: dismiss,
                    experience: experience
                ),
                label: {row}
            )
        } else {
            NavigationLink(
                destination: ChooseRouteView(
                    substance: substance,
                    dismiss: dismiss,
                    experience: experience
                ),
                label: {row}
            )
        }
    }

    private var row: some View {
        HStack {
            Text(substance.nameUnwrapped)
            Spacer()
        }
    }
}

struct SubstanceRow_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper()
        SubstanceRow(
            substance: helper.substance,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
