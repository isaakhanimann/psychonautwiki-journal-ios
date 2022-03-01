import SwiftUI

struct ChooseRouteView: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience

    var body: some View {
        List {
            ForEach(substance.administrationRoutesUnwrapped, id: \.self) { route in
                NavigationLink(
                    route.displayString,
                    destination: ChooseDoseView(
                        substance: substance,
                        administrationRoute: route,
                        dismiss: dismiss,
                        experience: experience
                    )
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Choose Route")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button("Cancel", action: dismiss)
            }
        }
    }
}

struct ChooseRouteView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        ChooseRouteView(
            substance: helper.substance,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
