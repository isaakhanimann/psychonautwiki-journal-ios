import SwiftUI

struct PrimaryButtonTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body.bold())
            .padding(.vertical)
            .frame(maxWidth: 500, minHeight: 44)
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
