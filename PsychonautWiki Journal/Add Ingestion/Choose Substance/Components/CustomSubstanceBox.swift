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
    let dismiss: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        if isEyeOpen {
            NavigationLink(value: CustomChooseRouteScreenArguments(substanceName: customSubstanceModel.name,
                                                                   units: customSubstanceModel.units)) {
                content
            }
        } else {
            NavigationLink(value: CustomChooseDoseScreenArguments(substanceName: customSubstanceModel.name,
                                                                  units: customSubstanceModel.units,
                                                                  administrationRoute: .oral)) {
                content
            }
        }
    }

    private var content: some View {
        GroupBox {
            if !customSubstanceModel.description.isEmpty {
                HStack {
                    Text(customSubstanceModel.description)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        } label: {
            HStack {
                Text(customSubstanceModel.name)
                Spacer()
                Text("custom").font(.subheadline).foregroundColor(.secondary)
            }
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
            dismiss: {},
            isEyeOpen: true
        ).padding(.horizontal)
    }
}
