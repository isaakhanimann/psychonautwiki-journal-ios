import SwiftUI
import SwiftyJSON

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
    @State private var isShowingErrorAlert = false
    @State private var errorMessage = ""

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
                        .accentColor(Color.orange)
                case .settings:
                    SettingsView(toggleSettingsVisibility: toggleSettingsVisibility)
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .accentColor(Color.orange)
                }
            })
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active {
                    calendarWrapper.checkIfSomethingChanged()
                }
            })
            .alert(isPresented: $isShowingErrorAlert, content: {
                Alert(
                    title: Text("Failed to Fetch"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            })
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

    private func maybeFetchNewSubstances() {

        guard hasBeenSetupBefore else { return }

        let oneWeek: TimeInterval = 60 * 60 * 24 * 7
        guard storedFile.first!.creationDateUnwrapped.distance(to: Date()) > oneWeek else {
            return
        }

        fetchNewSubstances()
    }

    private func fetchNewSubstances() {
        PsychonautWikiAPIController.performRequest { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                tryToDecodeData(data: data)
            }
        }
    }

    private func tryToDecodeData(data: Data) {
        do {
            let json = try JSON(data: data)
            let dataForFile = try json["data"].rawData()
            try SubstanceDecoder.decodeAndSaveFile(from: dataForFile)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isShowingErrorAlert.toggle()
            }
        }
    }
}
