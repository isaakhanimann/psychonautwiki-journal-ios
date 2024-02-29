// Copyright (c) 2024. Isaak Hanimann.
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

struct DoseClassificationRow: View {

    let lightMin: String?
    let commonMin: String?
    let strongMin: String?
    let heavyMin: String?
    let units: String

    var body: some View {
        let showDoseRow = lightMin != nil
            || commonMin != nil
            || strongMin != nil
            || heavyMin != nil
        if showDoseRow {
            HStack(alignment: .top, spacing: 0) {
                if let lightMin {
                    Spacer(minLength: 0)
                    VStack {
                        Text(lightMin)
                            .foregroundLinearGradient(colors: [DoseRangeType.thresh.color, DoseRangeType.light.color])
                            .font(doseFont)
                        Text("thresh ")
                            .fontWidth(.condensed)
                            .lineLimit(1)
                            .foregroundColor(DoseRangeType.thresh.color)
                            .font(.footnote)
                    }
                    Spacer(minLength: 0)
                }
                if lightMin != nil || commonMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("light")
                            .fontWidth(.condensed)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.light.color)
                    Spacer(minLength: 0)
                }
                if let commonMin {
                    Spacer(minLength: 0)
                    Text(commonMin)
                        .foregroundLinearGradient(colors: [DoseRangeType.light.color, DoseRangeType.common.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if commonMin != nil || strongMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("common")
                            .fontWidth(.condensed)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.common.color)
                    Spacer(minLength: 0)
                }
                if let strongMin {
                    Spacer(minLength: 0)
                    Text(strongMin)
                        .foregroundLinearGradient(colors: [DoseRangeType.common.color, DoseRangeType.strong.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if strongMin != nil || heavyMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("strong")
                            .fontWidth(.condensed)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.strong.color)
                    Spacer(minLength: 0)
                }
                if let heavyMin {
                    Spacer(minLength: 0)
                    Text(heavyMin)
                        .foregroundLinearGradient(colors: [DoseRangeType.strong.color, DoseRangeType.heavy.color])
                        .font(doseFont)
                    Spacer(minLength: 0)
                }
                if heavyMin != nil {
                    Spacer(minLength: 0)
                    VStack {
                        Text("-")
                            .font(doseFont)
                        Text("heavy")
                            .fontWidth(.condensed)
                            .lineLimit(1)
                            .font(.footnote)
                    }
                    .foregroundColor(DoseRangeType.heavy.color)
                    .font(doseFont)
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
                Text(units)
                    .font(doseFont)
                Spacer(minLength: 0)
            }
        } else {
            EmptyView()
        }
    }

    private var doseFont: Font {
        if
            let commonMin,
            commonMin.count >= 4
        {
            .footnote
        } else if
            let strongMin,
            strongMin.count >= 4
        {
            .footnote
        } else {
            .body
        }
    }

}

#Preview {
    DoseClassificationRow(
        lightMin: "20",
        commonMin: "60",
        strongMin: "100",
        heavyMin: "120",
        units: "mg")
}
