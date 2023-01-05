//
//  MDMAPillsSection.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 05.01.23.
//

import SwiftUI

struct MDMAPillsSection: View {
    var body: some View {
        Section("Pills") {
            Text("The average concentration of MDMA in ecstasy pills, tested in a drug checking program in Zurich, doubled between 2010 and 2018. The percentage of pills containing more than 120 mg MDMA rose from 4% to 73%.\nThe MDMA content of pills cannot be estimated visually. E.g. in Zurich pills that looked identical had differences of 220 mg in 2021. To determine the contents of your pills you need to test your substances quantitatively with free and anonymous testing services.")
            Link("EMCDDA Statistics", destination: URL(string: "https://www.emcdda.europa.eu/data/stats2022/ppp_en")!)
            Group {
                VStack(alignment: .leading) {
                    Text("Average Pill Switzerland 2021")
                    Text("175 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Switzerland 2021")
                    Text("300 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Weakest Pill Switzerland 2021")
                    Text("50 mg").font(.headline)
                }
            }
            Group {
                VStack(alignment: .leading) {
                    Text("Average Pill Netherlands 2020")
                    Text("160 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Netherlands 2020")
                    Text("310 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Weakest Pill Netherlands 2020")
                    Text("1 mg").font(.headline)
                }
            }
            Group {
                VStack(alignment: .leading) {
                    Text("Strongest Pill UK 2014")
                    Text("400 mg").font(.headline)
                }
            }
            Group {
                VStack(alignment: .leading) {
                    Text("Average Pill Belgium 2019")
                    Text("130 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Belgium 2019")
                    Text("410 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Belgium 2005")
                    Text("155 mg").font(.headline)
                }
            }
            Group {
                VStack(alignment: .leading) {
                    Text("Strongest Pill Germany 2018")
                    Text("210 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Germany 2017")
                    Text("450 mg").font(.headline)
                }
            }
            Group {
                VStack(alignment: .leading) {
                    Text("Average Pill Italy 2020")
                    Text("170 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Strongest Pill Italy 2020")
                    Text("280 mg").font(.headline)
                }
                VStack(alignment: .leading) {
                    Text("Average Pill Italy 2007")
                    Text("20 mg").font(.headline)
                }
            }
        }
    }
}

struct MDMAPillsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MDMAPillsSection()
        }
    }
}
