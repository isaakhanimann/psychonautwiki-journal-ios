import SwiftUI

struct ChooseRouteView: View {

    let substance: Substance
    @EnvironmentObject var sheetViewModel: SheetViewModel

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
                        administrationRoute: route
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
                                administrationRoute: route
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
                    sheetViewModel.dismiss()
                }
            }
        }
    }
}

struct ChooseRouteView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        NavigationView {
            ChooseRouteView(substance: helper.substance)
        }
    }
}
