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

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey1) var isEyeOpen1: Bool = false
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen2: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false

    var body: some View {
        ContentScreen(
            isShowingHome: $viewModel.isShowingHome,
            isShowingSearch: $viewModel.isShowingSearch,
            isShowingSafer: $viewModel.isShowingSafer,
            isShowingSettings: $viewModel.isShowingSettings,
            isEyeOpen: isEyeOpen2
        )
        .onOpenURL { url in
            viewModel.receiveURL(url: url)
        }
        .toast(isPresenting: $toastViewModel.isShowingToast) {
            AlertToast(
                displayMode: .alert,
                type: toastViewModel.isSuccessToast ? .complete(.green): .error(.red),
                title: toastViewModel.toastMessage
            )
        }
        .fullScreenCover(isPresented: $needsToSeeWelcome) {
            WelcomeScreen(isShowingWelcome: $needsToSeeWelcome)
        }
        .task {
            viewModel.toastViewModel = toastViewModel
            if !hasBeenMigrated2 {
                PersistenceController.shared.migrate()
                hasBeenMigrated2 = true
                isEyeOpen2 = isEyeOpen1
            }
        }
    }
}

struct ContentScreen: View {
    @Binding var isShowingHome: Bool
    @Binding var isShowingSearch: Bool
    @Binding var isShowingSafer: Bool
    @Binding var isShowingSettings: Bool
    let isEyeOpen: Bool

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: JournalScreen(),
                    isActive: $isShowingHome
                ) {
                    Label("Journal", systemImage: "house")
                }
                if isEyeOpen {
                    NavigationLink(
                        destination: SearchScreen(),
                        isActive: $isShowingSearch
                    ) {
                        Label("Substances", systemImage: "magnifyingglass")
                    }
                    NavigationLink(
                        destination: SaferScreen(),
                        isActive: $isShowingSafer
                    ) {
                        Label("Safer Use", systemImage: "cross")
                    }
                }
                NavigationLink(
                    destination: SettingsScreen(),
                    isActive: $isShowingSettings
                ) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }.navigationViewStyle(.stack)
    }
}


struct ContentScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(
            isShowingHome: .constant(false),
            isShowingSearch: .constant(false),
            isShowingSafer: .constant(false),
            isShowingSettings: .constant(false),
            isEyeOpen: false
        )
    }
}
