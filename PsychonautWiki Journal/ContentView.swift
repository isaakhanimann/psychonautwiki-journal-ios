import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasSeenWelcomeKey) var hasSeenWelcome: Bool = false

    var body: some View {
        ZStack {
            HandleUniversalURLView()
            Group {
                if hasSeenWelcome {
                    AllTabs()
                } else {
                    WelcomeScreen()
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
