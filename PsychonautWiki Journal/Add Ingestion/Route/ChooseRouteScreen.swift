import SwiftUI

struct ChooseRouteScreen: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        List {
            let administrationRoutesUnwrapped = substance.administrationRoutesUnwrapped
            if administrationRoutesUnwrapped.isEmpty {
                Text("No Documented Routes")
            }
            Section("Documented") {
                ForEach(administrationRoutesUnwrapped) { route in
                    NavigationLink {
                        ChooseDoseScreen(
                            substance: substance,
                            administrationRoute: route,
                            dismiss: dismiss
                        )
                    } label: {
                        Text(route.displayString)
                            .font(.title)
                            .padding(.vertical, 8)
                    }
                }
            }
            let otherRoutes = AdministrationRoute.allCases.filter { route in
                !administrationRoutesUnwrapped.contains(route)
            }
            Section("Undocumented") {
                ForEach(otherRoutes, id: \.self) { route in
                    NavigationLink(
                        route.displayString,
                        destination: ChooseDoseScreen(
                            substance: substance,
                            administrationRoute: route,
                            dismiss: dismiss
                        )
                    )
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
            ChooseRouteScreen(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                dismiss: {}
            )
        }
    }
}
