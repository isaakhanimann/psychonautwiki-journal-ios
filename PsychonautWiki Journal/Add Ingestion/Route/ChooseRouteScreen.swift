import SwiftUI

struct ChooseRouteScreen: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Documented Routes")
            let documentedRoutes = substance.administrationRoutesUnwrapped
            let numRows = Int(ceil(Double(documentedRoutes.count)/2.0))
            ForEach(0..<numRows, id: \.self) { index in
                HStack {
                    let route1 = documentedRoutes[index*2]
                    getRouteBoxFor(route: route1)
                    let secondIndex = index*2+1
                    if secondIndex < documentedRoutes.count {
                        let route2 = documentedRoutes[secondIndex]
                        getRouteBoxFor(route: route2)
                    }
                }
            }
            Text("Undocumented Routes")
            let otherRoutes = AdministrationRoute.allCases.filter { route in
                !documentedRoutes.contains(route)
            }
            let numOtherRows = Int(ceil(Double(otherRoutes.count)/2.0))
            ForEach(0..<numOtherRows, id: \.self) { index in
                HStack {
                    let route1 = otherRoutes[index*2]
                    getRouteBoxFor(route: route1)
                    let secondIndex = index*2+1
                    if secondIndex < otherRoutes.count {
                        let route2 = otherRoutes[secondIndex]
                        getRouteBoxFor(route: route2)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("\(substance.name) Routes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private func getRouteBoxFor(route: AdministrationRoute) -> some View {
        NavigationLink {
            if substance.name == "Cannabis" && route == .smoked {
                ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
            } else {
                ChooseDoseScreen(
                    substance: substance,
                    administrationRoute: route,
                    dismiss: dismiss
                )
            }
        } label: {
            GroupBox {
                VStack(alignment: .center) {
                    Text(route.rawValue.localizedCapitalized)
                        .font(.headline)
                    Text(route.clarification)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
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
