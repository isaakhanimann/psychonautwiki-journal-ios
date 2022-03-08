import SwiftUI

struct ChooseRouteView: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience?

    var body: some View {
        List {
            let administrationRoutesUnwrapped = substance.administrationRoutesUnwrapped
            ForEach(administrationRoutesUnwrapped, id: \.self) { route in
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
            let otherRoutes = Roa.AdministrationRoute.allCases.filter { route in
                !administrationRoutesUnwrapped.contains(route)
            }
            Section {
                DisclosureGroup("Other Routes") {
                    ForEach(otherRoutes, id: \.self) { route in
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
            }
        }
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
        NavigationView {
            ChooseRouteView(
                substance: helper.substance,
                dismiss: {},
                experience: helper.experiences.first!
            )
        }
    }
}
