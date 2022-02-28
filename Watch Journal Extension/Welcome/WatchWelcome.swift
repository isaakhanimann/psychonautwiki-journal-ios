import SwiftUI

struct WatchWelcome: View {

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @AppStorage(PersistenceController.hasSeenWelcomeKey) var hasSeenWelcome: Bool = false

    var imageName: String {
        isEyeOpen ? "AppIcon Open" : "AppIcon"
    }

    var body: some View {
        ScrollView {
            VStack {
                Image(decorative: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .accessibilityHidden(true)

                (Text("Welcome to ") + Text("PsychonautWiki").foregroundColor(.accentColor))
                    .font(.title3.bold())

                Button("Continue") {
                    hasSeenWelcome = true
                }
                .buttonStyle(BorderedButtonStyle(tint: .accentColor))
            }
        }
    }
}

struct WatchWelcome_Previews: PreviewProvider {
    static var previews: some View {
        WatchWelcome()
    }
}
