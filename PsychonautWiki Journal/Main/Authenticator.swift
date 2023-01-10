//
//  Authenticator.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 10.01.23.
//

import LocalAuthentication
import SwiftUI

@MainActor
class Authenticator: ObservableObject {

    private static let hasToUnlockKey = "hasToUnlockApp"
    @Published var hasToUnlockApp = false {
        didSet {
            UserDefaults.standard.set(hasToUnlockApp, forKey: Authenticator.hasToUnlockKey)
        }
    }
    @Published var isUnlocked = false
    @Published var isFaceIDEnabled = true

    init() {
        self.hasToUnlockApp = UserDefaults.standard.bool(forKey: Authenticator.hasToUnlockKey)
    }

    func onChange(of scenePhase: ScenePhase) {
        if scenePhase == .active {
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                isFaceIDEnabled = true
                if hasToUnlockApp {
                    authenticate(with: context)
                } else {
                    isUnlocked = true
                }
            } else {
                isFaceIDEnabled = false
                if !hasToUnlockApp {
                    isUnlocked = true
                }
            }
        } else if (scenePhase == .background || scenePhase == .inactive) && hasToUnlockApp {
            isUnlocked = false
        }
    }

    private func authenticate(with context: LAContext) {
        let reason = "Authenticate yourself to see your journal."
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            if success {
                Task { @MainActor in
                    self.isUnlocked = true
                }
            }
        }
    }

}
