import SwiftUI

struct WelcomeScreen: View {

    @Binding var isShowingWelcome: Bool
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
                        .onTapGesture(count: 3, perform: toggleEye)
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
                Button("I understand") {
                    isShowingWelcome.toggle()
                }
                .buttonStyle(.primary)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        playHapticFeedback()
    }

    let features = [
        Feature(
            title: "Risk & Reliability",
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
        WelcomeScreen(isShowingWelcome: .constant(true))
            .preferredColorScheme(.dark)
            .accentColor(Color.blue)
    }
}
