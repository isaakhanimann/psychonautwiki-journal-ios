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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CumulativeDoseRow_Previews: PreviewProvider {
    static var previews: some View {
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
        ).previewLayout(.sizeThatFits)
    }
}
