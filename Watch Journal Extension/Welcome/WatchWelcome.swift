import SwiftUI

struct WatchWelcome: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        ScrollView {
            VStack {
                Image(decorative: "AppIconCopy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .accessibilityHidden(true)

                (Text("Welcome to ") + Text("PsychonautWiki").foregroundColor(.accentColor))
                    .font(.title3.bold())

                Button("Continue") {
                    addInitialSubstances()
                    createExperience()
                    hasBeenSetupBefore = true
                }
                .buttonStyle(BorderedButtonStyle(tint: .accentColor))
            }
        }
        .navigationBarHidden(true)

    }

    private func addInitialSubstances() {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        do {
            let dateString = "2021/08/25 00:30"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let creationDate = formatter.date(from: dateString)!

            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                creationDate: creationDate,
                earlierFileToDelete: nil
            )
        } catch {
            fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
        }
    }

    private func createExperience() {
        let experience = Experience(context: moc)
        let now = Date()
        experience.creationDate = now
        experience.title = now.asDateString
        try? moc.save()
    }

}

struct WatchWelcome_Previews: PreviewProvider {
    static var previews: some View {
        WatchWelcome()
    }
}
