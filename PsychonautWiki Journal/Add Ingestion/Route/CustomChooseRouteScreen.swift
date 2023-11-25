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

struct CustomChooseRouteScreen: View {
    let substanceName: String
    let units: String
    let dismiss: () -> Void
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

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
                HStack {
                    getRouteBoxFor(route: .oral)
                    getRouteBoxFor(route: .insufflated)
                }
                HStack {
                    getRouteBoxFor(route: .smoked)
                    getRouteBoxFor(route: .inhaled)
                }
                HStack {
                    getRouteBoxFor(route: .sublingual)
                    getRouteBoxFor(route: .buccal)
                }
                HStack {
                    getRouteBoxFor(route: .rectal)
                    getRouteBoxFor(route: .transdermal)
                }
                HStack {
                    getRouteBoxFor(route: .subcutaneous)
                    getRouteBoxFor(route: .intravenous)
                }
                getRouteBoxFor(route: .intramuscular)
            }
            if isEyeOpen {
                NavigationLink {
                    SaferRoutesScreen()
                } label: {
                    Label("Safer Routes", systemImage: "info.circle")
                }.padding(.vertical)
            }
        }
        .padding(.horizontal)
        .navigationTitle("\(substanceName) Routes")
    }

    private func getRouteBoxFor(route: AdministrationRoute) -> some View {
        NavigationLink {
            CustomChooseDoseScreen(
                substanceName: substanceName,
                units: units,
                administrationRoute: route,
                dismiss: dismiss
            )
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

struct CustomChooseRouteScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomChooseRouteScreen(substanceName: "Coffee", units: "cups", dismiss: {})
        }
    }
}
