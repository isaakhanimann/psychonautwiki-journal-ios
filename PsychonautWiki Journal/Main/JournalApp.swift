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
import AlertToast

@main
struct JournalApp: App {
    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            JournalAuthenticatorWrapperView(authenticator: authenticator) {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                    .environmentObject(toastViewModel)
                    .environmentObject(authenticator)
                    .environmentObject(locationManager)
                    .accentColor(Color.blue)
                    .toast(isPresenting: $toastViewModel.isShowingToast, duration: 1) {
                        AlertToast(
                            displayMode: .alert,
                            type: toastViewModel.isSuccessToast ? .complete(.green) : .error(.red),
                            title: toastViewModel.toastMessage)
                    }
            }
        }
        .onChange(of: scenePhase) { phase in
            authenticator.onChange(of: phase)
        }
    }
}
