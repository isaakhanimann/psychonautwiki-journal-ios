import UIKit

func changeAppIcon(toOpen: Bool) {
    // nil sets it back to the default
    UIApplication.shared.setAlternateIconName(toOpen ? "AppIcon-Open" : nil) { error in
        if let errorUnwrap = error {
            assertionFailure(errorUnwrap.localizedDescription)
        }
    }
}

func playHapticFeedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}
