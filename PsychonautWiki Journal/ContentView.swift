import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var areSettingsShowing = false

    var body: some View {
        let sheetBinding = Binding<ActiveSheet?>(
            get: {
                if !hasBeenSetupBefore {
                    return ActiveSheet.setup
                } else if areSettingsShowing {
                    return ActiveSheet.settings
                } else {
                    return nil
                }
            },
            set: { _ in }
        )
        HomeView(toggleSettingsVisibility: toggleSettingsVisibility)
            .fullScreenCover(
                item: sheetBinding,
                content: { item in
                    switch item {
                    case .setup:
                        WelcomeScreen()
                            .environment(\.managedObjectContext, self.moc)
                            .environmentObject(calendarWrapper)
                            .accentColor(Color.blue)
                    case .settings:
                        SettingsView(toggleSettingsVisibility: toggleSettingsVisibility)
                            .environment(\.managedObjectContext, self.moc)
                            .environmentObject(calendarWrapper)
                            .accentColor(Color.blue)
                    }
                }
            )
            .onChange(
                of: scenePhase,
                perform: { newPhase in
                    if newPhase == .active {
                        calendarWrapper.checkIfSomethingChanged()
                        if shouldFetchAgain {
                            PsychonautWikiAPIController.fetchAndSaveNewSubstancesAndDeleteOldOnes(
                                oldFile: storedFile.first!
                            )
                        }
                    }
                }
            )
    }

    var shouldFetchAgain: Bool {
        guard !hasBeenSetupBefore else { return false }
        let oneDay: TimeInterval = 60 * 60 * 24 * 1
        guard storedFile.first!.creationDateUnwrapped.distance(to: Date()) > oneDay else {
            return false
        }
        return true
    }

    private func toggleSettingsVisibility() {
        areSettingsShowing.toggle()
    }

    enum ActiveSheet: Identifiable {
        case setup, settings

        // swiftlint:disable identifier_name
        var id: Int {
            hashValue
        }
    }
}
