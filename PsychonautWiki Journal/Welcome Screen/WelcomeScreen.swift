import SwiftUI

struct WelcomeScreen: View {

    @State private var isLoading = false
    @AppStorage(PersistenceController.hasSeenWelcomeKey) var hasSeenWelcome: Bool = false
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var imageName: String {
        isEyeOpen ? "Eye Open" : "Eye Closed"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    Image(decorative: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130, alignment: .center)
                        .padding(.leading, 10)
                    VStack(spacing: 20) {
                        (Text("Welcome to ") + Text("PsychonautWiki Journal").foregroundColor(.accentColor))
                            .multilineTextAlignment(.center)
                            .font(.largeTitle.bold())

                        ForEach(features) { feature in
                            HStack {
                                Image(systemName: feature.image)
                                    .frame(width: 44)
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading) {
                                    Text(feature.title)
                                        .font(.headline)

                                    Text(feature.description)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                Text("More info in Settings")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Button("I understand", action: loadAndDismiss)
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    private func loadAndDismiss() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            hasSeenWelcome = true
        }
    }

    let features = [
        Feature(
            title: "Risk & Reliability",
            // swiftlint:disable line_length
            description: "Any reliance you place on PsychonautWiki Journal is strictly at your own risk. The developer is not liable.",
            image: "brain.head.profile"
        ),
        Feature(
            title: "Third Party Resources",
            description: "All data in the app should be verified with other sources for accuracy.",
            image: "person.2.wave.2"
        ),
        Feature(
            title: "Consult a Doctor",
            description: "Consult a doctor before making medical decisions.",
            image: "heart.text.square"
        )
    ]
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
            .preferredColorScheme(.dark)
            .accentColor(Color.blue)
    }
}
