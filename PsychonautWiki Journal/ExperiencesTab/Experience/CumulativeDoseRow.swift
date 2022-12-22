//
//  CumulativeDoseRow.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 19.12.22.
//

import SwiftUI

struct CumulativeDoseRow: View {
    let substanceName: String
    let substanceColor: SubstanceColor
    let cumulativeRoutes: [CumulativeRouteAndDose]

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.title2)
                .foregroundColor(substanceColor.swiftUIColor)
            Text(substanceName)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
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
                Text(routeItem.route.rawValue.localizedCapitalized + " " + (routeItem.isEstimate ? "~": "") + doseUnwrapped.formatted() + " " + routeItem.units)
            } else {
                Text("Unknown Dose")
            }
            if let numDotsUnwrap = routeItem.numDots {
                DotRows(numDots: numDotsUnwrap)
            }
        }
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
            }
        }
    }
}
