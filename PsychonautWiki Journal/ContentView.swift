import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        ZStack {
            HandleUniversalURLView()
            Group {
                if hasBeenSetupBefore {
                    AllTabs()
                } else {
                    WelcomeScreen()
                        .environment(\.managedObjectContext, self.moc)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
