//
//  TestingScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 23.12.22.
//

import SwiftUI

struct TestingServicesScreen: View {
    var body: some View {
        List {
            Section("Austria") {
                TestingServiceItem(
                    name:"Drogenarbeit Z6",
                    city:"Innsbruck",
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
            Section("Spain") {
                TestingServiceItem(
                    name: "Energy Control",
                    city: "Various locations",
                    url: "https://energycontrol.org/servicio-de-analisis/"
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
        .headerProminence(.increased)
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

struct TestingServicesScreen_Previews: PreviewProvider {
    static var previews: some View {
        TestingServicesScreen()
    }
}
