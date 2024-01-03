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

import LocalAuthentication
import SwiftUI

@MainActor
class Authenticator: ObservableObject {
    static let hasToUnlockKey = "hasToUnlockApp"
    static let lockTimeOptionKey = "lockTimeOption"
    private static let lastDateKey = "lastDate"
    @Published var isLocked = true
    @Published var isFaceIDEnabled = true
    @Published var isStartingUp = true

    func onChange(of scenePhase: ScenePhase) {
        let hasToUnlockApp = UserDefaults.standard.bool(forKey: Authenticator.hasToUnlockKey)
        if scenePhase == .active {
            isStartingUp = false
            let context = LAContext()
            var error: NSError?
            let lockTimeOptionString = UserDefaults.standard.string(forKey: Authenticator.lockTimeOptionKey)
            let lockTimeOption = LockTimeOption(rawValue: lockTimeOptionString ?? "") ?? LockTimeOption.after5Minutes
            let lastDate = (UserDefaults.standard.object(forKey: Authenticator.lastDateKey) as? Date) ?? Date().addingTimeInterval(-2 * 60 * 60)
            let differenceNowToLastInSeconds = Date.now.timeIntervalSince1970 - lastDate.timeIntervalSince1970
            let isWithinToleratedTimeRange = differenceNowToLastInSeconds < lockTimeOption.timeInterval
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                isFaceIDEnabled = true
                // when the system shows the Face ID prompt the app moves to the background.
                // therefore this code gets executed before it is unlocked and after
                if hasToUnlockApp && isLocked && !isWithinToleratedTimeRange {
                    authenticate(with: context)
                }
            } else {
                isFaceIDEnabled = false
            }
            if !hasToUnlockApp || isWithinToleratedTimeRange {
                isLocked = false
            }
        } else if (scenePhase == .background || scenePhase == .inactive) && hasToUnlockApp && !isLocked {
            isLocked = true
            UserDefaults.standard.set(Date(), forKey: Authenticator.lastDateKey)
        }
    }

    private func authenticate(with context: LAContext) {
        let reason = "Authenticate yourself to see your journal."
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            if success {
                Task { @MainActor in
                    self.isLocked = false
                }
            }
        }
    }
}
