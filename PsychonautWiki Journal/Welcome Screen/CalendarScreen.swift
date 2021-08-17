import SwiftUI

struct CalendarScreen: View {

    @AppStorage("calendarIdentifier") var calendarIdentifier: String = ""

    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @State private var isShowingActionSheet = false
    @State private var isShowingAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
                .accessibilityHidden(true)
                .foregroundColor(.accentColor)

            Text("Sync to Calendar")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())

            Text(
                """
                Every new experience will be saved to Apple Calendar. \
                Even if you delete PsychonautWiki Journal, the saved events remain. \
                Once you have created the PsychonautWiki Calendar you can tap on "Calendars" \
                in Apple Calendars and deselect it such that its events are hidden.
                """
            )
            .foregroundColor(.secondary)

            Spacer()

            if calendarWrapper.authorizationStatus == .notDetermined {
                Button("Allow Access to Apple Calendar") {
                    calendarWrapper.requestAccess()
                }
                .buttonStyle(PrimaryButtonStyle())
                NavigationLink("Skip", destination: ImportSubstancesScreen())
            } else if calendarWrapper.authorizationStatus == .authorized {
                if calendarWrapper.psychonautWikiCalendar != nil {
                    Label("Your PsychonautWiki Calendar is All Set", systemImage: "checkmark")
                        .font(.title2)
                        .foregroundColor(.green)
                    Spacer()
                    NavigationLink(
                        destination: ImportSubstancesScreen(),
                        label: {
                            Text("Continue")
                                .primaryButtonText()
                        }
                    )
                } else {
                    Button("Create PsychonautWiki Calendar") {
                        isShowingActionSheet.toggle()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    NavigationLink("Skip", destination: ImportSubstancesScreen())
                }
            } else {
                Text("Please Enable Calendar Access in your iPhone Settings")
                NavigationLink("Next", destination: ImportSubstancesScreen())
            }
        }
        .padding()
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(
                title: Text("Select Account"),
                message: Text("Select an account for creating the PsychonautWiki calendar. iCloud recommended"),
                buttons: actionSheetButtons
            )
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Failed to Create Calendar"),
                message: Text("Do you have the Apple Calendar App installed?"),
                dismissButton: .default(Text("Ok"))
            )
        }
        .navigationBarHidden(true)
    }

    private var actionSheetButtons: [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        for source in calendarWrapper.getSources() {
            let button = ActionSheet.Button.default(Text(source.title)) {
                do {
                    try calendarWrapper.createPsychonautWikiCalendar(with: source)
                } catch {
                    isShowingAlert.toggle()
                }
            }
            buttons.append(button)
        }
        return buttons
    }

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    private func addSampleSubstancesAndDismiss() {
        let fileName = "Sample Substances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        do {
            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                with: fileName,
                selectFile: true,
                markFileAsNew: false
            )
        } catch {
            fatalError("Failed to decode \(fileName) from bundle")
        }

        hasBeenSetupBefore = true
    }
}

struct CalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CalendarScreen()
    }
}
