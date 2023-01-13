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

import Foundation

extension ContentView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isShowingHome = true
        @Published var isShowingSearch = false
        @Published var isShowingSafer = false
        @Published var isShowingSettings = false

        var toastViewModel: ToastViewModel?

        func receiveURL(url: URL) {
            if url.absoluteString == OpenJournalURL {
                isShowingHome = true
                isShowingSearch = false
                isShowingSafer = false
                isShowingSettings = false
            } else {
                if !UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2) {
                    UserDefaults.standard.set(true, forKey: PersistenceController.isEyeOpenKey2)
                    self.toastViewModel?.showSuccessToast(message: "Unlocked")
                } else {
                    self.toastViewModel?.showSuccessToast(message: "Already Unlocked")
                }
            }
        }
    }
}
