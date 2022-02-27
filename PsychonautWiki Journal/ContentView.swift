import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var calendarWrapper: CalendarWrapper
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
                        .environmentObject(calendarWrapper)
                        .accentColor(Color.blue)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
