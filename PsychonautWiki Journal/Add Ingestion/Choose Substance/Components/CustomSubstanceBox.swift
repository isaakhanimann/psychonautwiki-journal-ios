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

struct CustomSubstanceBox: View {
    let customSubstanceModel: CustomSubstanceModel
    let isEyeOpen: Bool

    var body: some View {
        if isEyeOpen {
            NavigationLink(value: CustomSubstanceChooseRouteScreenArguments(substanceName: customSubstanceModel.name,
                                                                   units: customSubstanceModel.units)) {
                content
            }.overlay(alignment: .bottom) {
                Divider()
            }
        } else {
            NavigationLink(value: CustomChooseDoseScreenArguments(substanceName: customSubstanceModel.name,
                                                                  units: customSubstanceModel.units,
                                                                  administrationRoute: .oral)) {
                content
            }.overlay(alignment: .bottom) {
                Divider()
            }
        }
    }

    private var content: some View {
        NavigatableListItemContent(title: customSubstanceModel.name) {
            Text("custom")
        }
    }
}

#Preview {
    NavigationStack {
        CustomSubstanceBox(
            customSubstanceModel: CustomSubstanceModel(
                name: "Coffee",
                description: "The bitter drink",
                units: "cups"
            ),
            isEyeOpen: true
        )
    }
}
