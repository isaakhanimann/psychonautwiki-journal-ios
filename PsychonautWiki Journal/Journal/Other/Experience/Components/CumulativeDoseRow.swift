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

struct CumulativeDoseRow: View {
    let substanceName: String
    let substanceColor: SubstanceColor
    let cumulativeRoutes: [CumulativeRouteAndDose]
    let isHidingDosageDots: Bool
    let isEyeOpen: Bool

    var body: some View {
        HStack {
            ColorRectangle(color: substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                Text(substanceName)
                    .font(.headline)
                    .foregroundColor(.primary)
                VStack {
                    ForEach(cumulativeRoutes) { routeItem in
                        RouteItemView(
                            routeItem: routeItem,
                            isHidingDosageDots: isHidingDosageDots,
                            isEyeOpen: isEyeOpen
                        )
                    }
                }
            }
        }
    }
}

struct RouteItemView: View {
    let routeItem: CumulativeRouteAndDose
    let isHidingDosageDots: Bool
    let isEyeOpen: Bool

    var body: some View {
        HStack {
            let routeText = isEyeOpen ? routeItem.route.rawValue : ""
            if let doseUnwrapped = routeItem.dose {
                Text("\(routeItem.isEstimate ? "~": "")\(doseUnwrapped.formatted()) \(routeItem.units) \(routeText)").multilineTextAlignment(.trailing)
            } else {
                Text("Unknown dose \(routeText)")
            }
            Spacer()
            if let numDotsUnwrap = routeItem.numDots, !isHidingDosageDots {
                DotRows(numDots: numDotsUnwrap)
            }
        }.font(.subheadline)
    }
}

struct CumulativeDoseRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                CumulativeDoseRow(
                    substanceName: "MDMA",
                    substanceColor: .pink,
                    cumulativeRoutes: [
                        CumulativeRouteAndDose(
                            route: .oral,
                            numDots: 5,
                            isEstimate: false,
                            dose: 250,
                            units: "mg"
                        ),
                        CumulativeRouteAndDose(
                            route: .insufflated,
                            numDots: 1,
                            isEstimate: true,
                            dose: 20,
                            units: "mg"
                        )
                    ],
                    isHidingDosageDots: false,
                    isEyeOpen: true
                )
                CumulativeDoseRow(
                    substanceName: "Amphetamine",
                    substanceColor: .blue,
                    cumulativeRoutes: [
                        CumulativeRouteAndDose(
                            route: .oral,
                            numDots: 3,
                            isEstimate: false,
                            dose: 30,
                            units: "mg"
                        ),
                        CumulativeRouteAndDose(
                            route: .insufflated,
                            numDots: nil,
                            isEstimate: true,
                            dose: nil,
                            units: "mg"
                        )
                    ],
                    isHidingDosageDots: false,
                    isEyeOpen: true
                )
            }
        }
    }
}
