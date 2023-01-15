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

@main
struct PsychonautWiki_JournalApp: App {

    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if authenticator.isStartingUp {
                LockScreen(isEyeOpen: true, isFaceIDEnabled: true)
            } else {
                if authenticator.isUnlocked {
                    ContentView()
                        .headerProminence(.increased)
                        .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                        .environmentObject(toastViewModel)
                        .environmentObject(authenticator)
                        .environmentObject(locationManager)
                        .accentColor(Color.blue)
                } else {
                    LockScreen(isEyeOpen: false, isFaceIDEnabled: authenticator.isFaceIDEnabled)
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            authenticator.onChange(of: phase)
        }
    }
}
