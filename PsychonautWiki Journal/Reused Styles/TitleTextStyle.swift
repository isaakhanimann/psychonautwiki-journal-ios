import SwiftUI

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(.largeTitle.bold())
    }
}

extension View {
    func titleStyle() -> some View {
        self.modifier(TitleTextStyle())
    }
}
