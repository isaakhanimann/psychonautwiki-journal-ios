import SwiftUI

struct ChooseRouteView: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        List {
            let administrationRoutesUnwrapped = substance.administrationRoutesUnwrapped
            if administrationRoutesUnwrapped.isEmpty {
                Text("No Routes Defined by PsychonautWiki")
            }
            ForEach(administrationRoutesUnwrapped) { route in
                NavigationLink(
                    route.displayString,
                    destination: ChooseDoseView(
                        substance: substance,
                        administrationRoute: route,
                        dismiss: dismiss
                    )
                )
            }
            let otherRoutes = AdministrationRoute.allCases.filter { route in
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
                                dismiss: dismiss
                            )
                        )
                    }
                }
            }
        }
        .navigationBarTitle("Choose Route")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct ChooseRouteView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ChooseRouteView(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                dismiss: {}
            )
        }
    }
}
