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

struct OneRoaDurationRow: View {

    let duration: RoaDuration
    let color: SubstanceColor

    var body: some View {
        VStack {
            HStack {
                if let onset = duration.onset?.displayString {
                    DurationChip(name: "onset", text: onset, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let comeup = duration.comeup?.displayString {
                    DurationChip(name: "comeup", text: comeup, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let peak = duration.peak?.displayString {
                    DurationChip(name: "peak", text: peak, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                if let offset = duration.offset?.displayString {
                    DurationChip(name: "offset", text: offset, color: color)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
            }
            HStack {
                if let total = duration.total?.displayString {
                    Text("total: \(total)")
                }
                Spacer()
                if let afterglow = duration.afterglow?.displayString {
                    Text("after effects: \(afterglow)")
                }
            }
        }
        .font(.footnote)
    }
}

struct DurationChip: View {
    let name: String
    let text: String
    let color: SubstanceColor

    var body: some View {
        VStack {
            Text(text)
            Text(name)
        }.padding(5)
            .background(color.swiftUIColor.opacity(shapeOpacity))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    OneRoaDurationRow(
                        duration: SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!.getDuration(for: .smoked)!,
                        color: .blue
                    )
                }
            }
        }
    }
}
