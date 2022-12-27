//
//  RootScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 27.12.22.
//

import SwiftUI

struct RootScreen: View {
    @State var isShowingHome = true

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: HomeScreen(),
                    isActive: $isShowingHome
                ) {
                    Label("Journal", systemImage: "house")
                }
                NavigationLink(
                    destination: SearchScreen()
                ) {
                    Label("Substances", systemImage: "magnifyingglass")
                }
                NavigationLink(
                    destination: SaferScreen()
                ) {
                    Label("Safer Use", systemImage: "cross")
                }
                NavigationLink(
                    destination: SettingsScreen()
                ) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(isShowingHome: false)
    }
}
