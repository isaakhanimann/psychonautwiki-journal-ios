import SwiftUI
import EventKit

struct CalendarSection: View {

    @ObservedObject var experience: Experience
    @EnvironmentObject private var calendarWrapper: CalendarWrapper

    var body: some View {
        Section(
            header: Text("Sync to Calendar"),
            footer: footer
        ) {
            if calendarWrapper.authorizationStatus == .notDetermined {
                Button("Allow Access to Apple Calendar") {
                    calendarWrapper.requestAccess()
                }
            } else if calendarWrapper.authorizationStatus == .authorized {
                if calendarWrapper.psychonautWikiCalendar != nil {
                    Button {
                        calendarWrapper.createOrUpdateEvent(from: experience)
                        try? PersistenceController.shared.viewContext.save()
                    } label: {
                        Label("Sync Now", systemImage: "arrow.clockwise")
                    }
                } else {
                    Button("Create PsychonautWiki Calendar", action: calendarWrapper.showActionSheet)
                }
            } else {
                Text("Enable Calendar Access in your iPhone Settings")
            }
        }
        .actionSheet(isPresented: $calendarWrapper.isShowingActionSheet) {
            ActionSheet(
                title: Text("Select Account"),
                message: Text("Select an account for creating the PsychonautWiki calendar. iCloud recommended"),
                buttons: actionSheetButtons
            )
        }
        .alert(isPresented: $calendarWrapper.isShowingAlert) {
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
                calendarWrapper.createPsychonautWikiCalendar(with: source)
            }
            buttons.append(button)
        }
        return buttons
    }
}
