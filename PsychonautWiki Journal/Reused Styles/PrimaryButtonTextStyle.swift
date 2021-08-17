import SwiftUI

struct PrimaryButtonTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    func primaryButtonText() -> some View {
        self.modifier(PrimaryButtonTextStyle())
    }
}
