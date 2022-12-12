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
        List {
            Section {
                ForEach(AdministrationRoute.allCases, id: \.self) { route in
                    NavigationLink {
                        CustomChooseDoseScreen(
                            substanceName: substanceName,
                            units: units,
                            administrationRoute: route,
                            dismiss: dismiss
                        )
                    } label: {
                        Text(route.displayString)
                            .font(.title2)
                            .padding(.vertical, 6)
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

struct CustomChooseRouteScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomChooseRouteScreen(substanceName: "Coffee", units: "cup", dismiss: {})
    }
}
