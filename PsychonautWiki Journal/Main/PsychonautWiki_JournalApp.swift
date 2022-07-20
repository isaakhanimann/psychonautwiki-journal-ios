import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var calendarWrapper = CalendarWrapper()
    @StateObject private var sheetViewModel = SheetViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationViewStyle(.stack)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(calendarWrapper)
                .environmentObject(sheetViewModel)
                .environmentObject(toastViewModel)
                .accentColor(Color.blue)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                appHasBecomeActive()
            } else if phase == .background {
                PersistenceController.shared.saveViewContext()
                appDelegate.scheduleSubstancesRefresh()
            }
        }
    }

    private func appHasBecomeActive() {
        calendarWrapper.checkIfSomethingChanged()
    }
}
