// Copyright (c) 2023. Isaak Hanimann.
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

struct ChooseOtherRouteScreen: View {
    let arguments: ChooseOtherRouteScreenArguments
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
            let numRows = Int(ceil(Double(arguments.otherRoutes.count) / 2.0))
            ForEach(0 ..< numRows, id: \.self) { index in
                HStack {
                    let route1 = arguments.otherRoutes[index * 2]
                    getRouteBoxWithNavigation(route: route1)
                    let secondIndex = index * 2 + 1
                    if secondIndex < arguments.otherRoutes.count {
                        let route2 = arguments.otherRoutes[secondIndex]
                        getRouteBoxWithNavigation(route: route2)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("Other Routes")
    }

    private func getRouteBoxWithNavigation(route: AdministrationRoute) -> some View {
        NavigationLink(value: SubstanceAndRoute(substance: arguments.substance, administrationRoute: route)) {
            RouteBox(route: route)
        }
    }
}

#Preview {
    ChooseOtherRouteScreen(
        arguments: .init(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                         otherRoutes: [.inhaled, .intravenous, .intramuscular, .smoked]),
        dismiss: {}
    )
}
