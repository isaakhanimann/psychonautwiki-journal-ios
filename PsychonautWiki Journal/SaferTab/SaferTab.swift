//
//  SaferTab.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 06.12.22.
//

import SwiftUI

struct SaferTab: View {
    var body: some View {
        NavigationView {
            Text("Hello")
                .navigationTitle("Safer Use")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsScreen()) {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
        }
    }
}

struct SaferTab_Previews: PreviewProvider {
    static var previews: some View {
        SaferTab()
    }
}
