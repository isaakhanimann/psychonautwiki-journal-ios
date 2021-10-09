import SwiftUI

struct WatchWelcome: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

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
                    hasBeenSetupBefore = true
                }
                .buttonStyle(BorderedButtonStyle(tint: .accentColor))
            }
        }
        .onAppear {
            if storedFile.first == nil {
                PersistenceController.shared.addInitialSubstances()
                _ = PersistenceController.shared.createNewExperienceNow()
            }
        }
    }
}

struct WatchWelcome_Previews: PreviewProvider {
    static var previews: some View {
        WatchWelcome()
    }
}
