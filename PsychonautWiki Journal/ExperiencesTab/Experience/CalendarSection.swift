import SwiftUI
import EventKit

struct CalendarSection: View {

    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @State private var isShowingActionSheet = false
    @State private var isShowingAlert = false
    @ObservedObject var experience: Experience

    var body: some View {
        Section(
            header: Text("Sync Experience to Your Calendar"),
            footer: footer
        ) {
            if calendarWrapper.authorizationStatus == .notDetermined {
                Button("Allow Access to Apple Calendar") {
                    calendarWrapper.requestAccess()
                }
            } else if calendarWrapper.authorizationStatus == .authorized {
                if calendarWrapper.psychonautWikiCalendar != nil {
                    Button {
                        experience.objectWillChange.send()
                        calendarWrapper.createOrUpdateEvent(from: experience)
                        try? PersistenceController.shared.viewContext.save()
                    } label: {
                        Label("Sync Now", systemImage: "arrow.clockwise")
                    }
                } else {
                    Button(action: {
                        isShowingActionSheet.toggle()
                    }, label: {
                        Text("Create PsychonautWiki Calendar")
                    })
                }
            } else {
                Text("Please Enable Calendar Access in your iPhone Settings")
            }
        }
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
    }

    private var footer: Text {
        if calendarWrapper.isSetupComplete {
            return Text("Last Sync: \(experience.lastSyncToCalendar?.asDateAndTime ?? "-")")
        } else {
            return Text("")
        }
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
}
