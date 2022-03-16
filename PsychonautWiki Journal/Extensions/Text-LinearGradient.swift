import SwiftUI

extension Text {
    public func foregroundLinearGradient(colors: [Color]) -> some View {
        self.overlay {
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            ).mask(
                self
            )
        }
    }
}
