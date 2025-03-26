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

struct TestingServicesScreen: View {
    var body: some View {
        List {
            Section("Austria") {
                TestingServiceItem(
                    name: "Drogenarbeit Z6",
                    city: "Innsbruck",
                    url: "https://www.drogenarbeitz6.at/drug-checking.html"
                )
                TestingServiceItem(
                    name: "Checkit!",
                    city: "Vienna",
                    url: "https://checkit.wien/drug-checking-2/"
                )
                TestingServiceItem(
                    name: "Triptalks",
                    city: "Graz",
                    url: "https://triptalks.at"
                )
            }
            Section("Australia") {
                TestingServiceItem(
                    name: "CanTEST",
                    city: "Canberra",
                    url: "https://www.cahma.org.au/services/cantest/"
                )
                TestingServiceItem(
                    name: "CheQpoint",
                    city: "Queensland",
                    url: "https://www.quihn.org/cheqpoint/"
                )
            }
            Section("Belgium") {
                TestingServiceItem(
                    name: "Modus Vivendi",
                    city: "Saint-Gilles",
                    url: "https://www.modusvivendi-be.org"
                )
                TestingServiceItem(
                    name: "Exaequo @ Rainbowhouse",
                    city: "Brussels",
                    url: "https://www.exaequo.be"
                )
            }
            Section("Canada") {
                TestingServiceItem(
                    name: "Get Your Drugs Tested",
                    city: "Vancouver",
                    url: "http://www.vch.ca/public-health/harm-reduction/overdose-prevention-response/drug-checking"
                )
                TestingServiceItem(
                    name: "grip",
                    city: "Montreal",
                    url: "https://grip-prevention.ca/en/drug-checking/"
                )
            }
            Section("Germany") {
                TestingServiceItem(
                    name: "Drugchecking",
                    city: "Berlin",
                    url: "https://drugchecking.berlin"
                )
            }
            Section("France") {
                TestingServiceItem(
                    name: "Asso Michel - CAARUD Médiane",
                    city: "Dunkerque",
                    url: "https://www.associationmichel.com/caarud-mediane-722/le-caarud-mediane-743/"
                )
                TestingServiceItem(
                    name: "Le MAS - CAARUD Pause diabolo",
                    city: "Lyon",
                    url: "https://www.mas-asso.fr/service/pause-diabolo/"
                )
                TestingServiceItem(
                    name: "Centre \"Les Wads\"",
                    city: "Metz",
                    url: "http://www.leswadscmsea.fr"
                )
            }
            Section("Italy") {
                TestingServiceItem(
                    name: "Neutravel Project",
                    city: "Torino",
                    url: "https://www.neutravel.net/drug-checking"
                )
            }
            Section("Netherlands") {
                TestingServiceItem(
                    name: "Drugs-test",
                    city: "33 locations",
                    url: "https://www.drugs-test.nl/en/testlocations/"
                )
            }
            Section("Norway") {
                TestingServiceItem(
                    name:"Rusopplysningen",
                    city:"Oslo",
                    url:"https://rusopplysningen.no/analysetjeneste"
                )
            }
            Section("Slovenia") {
                TestingServiceItem(
                    name: "DrogArt",
                    city: "Various locations",
                    url: "https://www.drogart.org/testirne-tocke/"
                )
            }
            Section("Spain") {
                TestingServiceItem(
                    name: "Energy Control",
                    city: "Various locations",
                    url: "https://energycontrol.org/servicio-de-analisis/"
                )
                TestingServiceItem(
                    name: "CHEMSAFE",
                    city: "Various locations",
                    url: "https://www.chem-safe.org/check-your-chems/"
                )
                TestingServiceItem(
                    name: "Kykeon Analytics",
                    city: "Various locations",
                    url: "https://www.kykeonanalytics.com"
                )
                TestingServiceItem(
                    name: "Ai Laket",
                    city: "Vitoria-Gasteiz, Bilbo and Donosti",
                    url: "https://ailaket.com/proyectos/punto-fijo/"
                )
            }
            Section("Switzerland") {
                TestingServiceItem(
                    name: "DIBS / Safer Dance Basel",
                    city: "Basel",
                    url: "https://de.saferdancebasel.ch/drugchecking"
                )
                TestingServiceItem(
                    name: "DIB / rave it safe",
                    city: "Bern, Biel",
                    url: "https://www.raveitsafe.ch/angebotsdetails/dib-drug-checking-bern/"
                )
                TestingServiceItem(
                    name: "Nuit Blanche",
                    city: "Geneva",
                    url: "https://nuit-blanche.ch/drug-checking/"
                )
                TestingServiceItem(
                    name: "DIZ / Saferparty",
                    city: "Zurich",
                    url: "https://en.saferparty.ch/angebote/drug-checking"
                )
                TestingServiceItem(
                    name: "DILU Luzern",
                    city: "Luzern",
                    url: "https://www.gassenarbeit.ch/angebote/dilu"
                )
                TestingServiceItem(
                    name:"NightLife Vaud",
                    city:"Lausanne",
                    url:"https://nightlifevaud.ch/permanence/"
                )
            }
            Section("United Kingdom") {
                TestingServiceItem(
                    name: "The Loop",
                    city: "Bristol",
                    url: "https://wearetheloop.org"
                )
            }
            Section {
                Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                    Label("Report missing service", systemImage: "plus.bubble.fill")
                }.foregroundColor(.red)
            }
        }
        .navigationTitle("Testing Services")
    }
}

struct TestingServiceItem: View {
    let name: String
    let city: String
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(alignment: .leading) {
                Text(name).font(.headline)
                Text(city).font(.subheadline)
            }
        }
    }
}

#Preview {
    TestingServicesScreen()
}
