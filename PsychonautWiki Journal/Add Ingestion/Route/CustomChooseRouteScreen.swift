//
//  CustomChooseRouteScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 12.12.22.
//

import SwiftUI

struct CustomChooseRouteScreen: View {
    let substanceName: String
    let units: String
    let dismiss: () -> Void

    var body: some View {
        VStack {
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
            HStack {
                getRouteBoxFor(route: .intramuscular)
                GroupBox{}.hidden().frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }
        }
        .padding(.horizontal)
        .navigationTitle("\(substanceName) Route")
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
