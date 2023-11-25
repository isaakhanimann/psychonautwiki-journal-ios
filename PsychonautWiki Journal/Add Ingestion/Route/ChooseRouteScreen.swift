// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct ChooseRouteScreen: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    var screen: some View {
        VStack(alignment: .leading) {
            let documentedRoutes = substance.administrationRoutesUnwrapped
            if !documentedRoutes.isEmpty {
                Text("Documented Routes").sectionHeaderStyle()
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
            }
            let otherRoutes = AdministrationRoute.allCases.filter { route in
                !documentedRoutes.contains(route)
            }
            if !otherRoutes.isEmpty {
                Text("Undocumented Routes").sectionHeaderStyle()
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
            NavigationLink {
                SaferRoutesScreen()
            } label: {
                GroupBox {
                    Label("Safer Routes", systemImage: "info.circle")
                        .font(.headline)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            alignment: .center
                        )
                }
                .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("\(substance.name) Routes")
    }

    private func getRouteBoxFor(route: AdministrationRoute) -> some View {
        NavigationLink {
            if substance.name == "Cannabis" && route == .smoked {
                ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
            } else if substance.name == "Alcohol" && route == .oral {
                ChooseAlcoholDoseScreen(dismiss: dismiss)
            } else if substance.name == "Caffeine" && route == .oral {
                ChooseCaffeineDoseScreen(dismiss: dismiss)
            } else if substance.name == "MDMA" && route == .oral {
                ChooseMDMADoseScreen(dismiss: dismiss)
            } else if substance.name == "Psilocybin mushrooms" && route == .oral {
                ChooseShroomsDoseScreen(dismiss: dismiss)
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
                        .font(.footnote)
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
        Group {
            ForEach(previewDeviceNames, id: \.self) { name in
                NavigationView {
                    ChooseRouteScreen(
                        substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                        dismiss: {}
                    )
                }
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
            }
        }
    }
}
