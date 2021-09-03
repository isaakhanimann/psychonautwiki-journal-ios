import SwiftUI
import SwiftyJSON

struct WatchWelcome: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                Image(decorative: "AppIconCopy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .accessibilityHidden(true)

                (Text("Welcome to ") + Text("PsychonautWiki Journal").foregroundColor(.accentColor))
                    .font(.title3.bold())

                Button("Continue", action: addInitialSubstances)
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
            let json = try JSON(data: data)
            let dataForFile = try json["data"].rawData()

            let dateString = "2021/08/25 00:30"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let creationDate = formatter.date(from: dateString)!

            try SubstanceDecoder.decodeAndSaveFile(
                from: dataForFile,
                creationDate: creationDate,
                earlierFileToDelete: nil
            )
        } catch {
            fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
        }

        hasBeenSetupBefore = true
    }
}

struct WatchWelcome_Previews: PreviewProvider {
    static var previews: some View {
        WatchWelcome()
    }
}
