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
        VStack(alignment: .leading) {
            HStack {
                if let onset = duration.onset?.displayString {
                    DurationChip(name: "onset", text: onset, color: color)
                }
                if let comeup = duration.comeup?.displayString {
                    DurationChip(name: "comeup", text: comeup, color: color)
                }
                if let peak = duration.peak?.displayString {
                    DurationChip(name: "peak", text: peak, color: color)
                }
                if let offset = duration.offset?.displayString {
                    DurationChip(name: "offset", text: offset, color: color)
                }
            }
            HStack {
                if let total = duration.total?.displayString {
                    Text("total: \(total)")
                        .colorBackground(color)
                }
                if let afterglow = duration.afterglow?.displayString {
                    Text("after effects: \(afterglow)")
                        .colorBackground(color)
                }
            }
        }
        .font(.footnote)
    }
}

#Preview {
    NavigationStack {
        List {
            OneRoaDurationRow(
                duration: SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!.getDuration(for: .smoked)!,
                color: .blue
            )
            OneRoaDurationRow(
                duration: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDuration(for: .oral)!,
                color: .pink
            )
            OneRoaDurationRow(
                duration: SubstanceRepo.shared.getSubstance(name: "LSD")!.getDuration(for: .sublingual)!,
                color: .purple
            )
        }
    }
}
