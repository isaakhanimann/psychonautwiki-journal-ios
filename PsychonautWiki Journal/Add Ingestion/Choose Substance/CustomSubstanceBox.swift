//
//  CustomSubstanceBox.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

import SwiftUI

struct CustomSubstanceBox: View {

    let customSubstanceModel: CustomSubstanceModel
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            CustomChooseRouteScreen(
                substanceName: customSubstanceModel.name,
                units: customSubstanceModel.units,
                dismiss: dismiss
            )
        } label: {
            GroupBox(customSubstanceModel.name) {}
        }

    }
}

struct CustomSubstanceBox_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomSubstanceBox(customSubstanceModel: CustomSubstanceModel(name: "Coffee", units: "cups"), dismiss: {}).padding(.horizontal)
        }
    }
}
