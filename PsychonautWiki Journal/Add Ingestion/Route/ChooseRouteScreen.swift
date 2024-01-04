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
        VStack(alignment: .center) {
            VStack(alignment: .leading) {
                let documentedRoutes = substance.administrationRoutesUnwrapped
                let otherRoutes = AdministrationRoute.allCases.filter { route in
                    !documentedRoutes.contains(route)
                }
                if documentedRoutes.isEmpty {
                    getGroupOfRoutes(routes: otherRoutes)
                } else {
                    getGroupOfRoutes(routes: documentedRoutes)
                    if !otherRoutes.isEmpty {
                        NavigationLink(value: ChooseOtherRouteScreenArguments(substance: substance,
                                                                              otherRoutes: otherRoutes)) {
                            GroupBox {
                                Text("Other Routes")
                                    .font(.headline)
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
            }
            NavigationLink(value: AddIngestionDestination.saferRoutes) {
                Label("Safer Routes", systemImage: "info.circle")
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
        .navigationBarTitle("\(substance.name) Routes")
    }

    @ViewBuilder
    private func getGroupOfRoutes(routes: [AdministrationRoute]) -> some View {
        let numOfRoutes = routes.count
        if numOfRoutes < 6 {
            ForEach(routes, id: \.self) { route in
                getRouteBoxWithNavigation(route: route)
            }
        } else {
            let numRows = Int(ceil(Double(routes.count) / 2.0))
            ForEach(0 ..< numRows, id: \.self) { index in
                HStack {
                    let route1 = routes[index * 2]
                    getRouteBoxWithNavigation(route: route1)
                    let secondIndex = index * 2 + 1
                    if secondIndex < routes.count {
                        let route2 = routes[secondIndex]
                        getRouteBoxWithNavigation(route: route2)
                    }
                }
            }
        }
    }

    private func getRouteBoxWithNavigation(route: AdministrationRoute) -> some View {
        NavigationLink(value: SubstanceAndRoute(substance: substance, administrationRoute: route)) {
            RouteBox(route: route)
        }
    }
}

#Preview {
    NavigationStack {
        ChooseRouteScreen(
            substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
            dismiss: {}
        )
    }
}
