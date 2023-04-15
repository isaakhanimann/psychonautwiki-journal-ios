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

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .foregroundColor(substanceColor.swiftUIColor)
                Text(substanceName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            VStack(alignment: .trailing, spacing: 4) {
                ForEach(cumulativeRoutes) { routeItem in
                    RouteItemView(routeItem: routeItem)
                }
            }
        }
    }
}

struct RouteItemView: View {
    let routeItem: CumulativeRouteAndDose

    var body: some View {
        HStack {
            if let doseUnwrapped = routeItem.dose {
                Text((routeItem.isEstimate ? "~": "") + doseUnwrapped.formatted() + " " + routeItem.units).multilineTextAlignment(.trailing)
            } else {
                Text("Unknown Dose")
            }
            Text(routeItem.route.rawValue.localizedCapitalized)
            Spacer()
            if let numDotsUnwrap = routeItem.numDots {
                DotRows(numDots: numDotsUnwrap)
            }
        }.font(.subheadline.weight(.semibold))
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
                    ]
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
                    ]
                )
            }
        }
    }
}
