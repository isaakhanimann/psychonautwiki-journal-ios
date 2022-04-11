import SwiftUI
import EventKit

struct CalendarSectionInSettings: View {

    @EnvironmentObject private var calendarWrapper: CalendarWrapper
    @EnvironmentObject private var toastViewModel: ToastViewModel

    var body: some View {
        Section("Calendar") {
            if calendarWrapper.authorizationStatus == .notDetermined {
                Button("Allow Access to Apple Calendar") {
                    calendarWrapper.requestAccess()
                }
            } else if calendarWrapper.authorizationStatus == .authorized {
                if calendarWrapper.psychonautWikiCalendar != nil {
                    Button {
                        syncAllExperiences()
                    } label: {
                        Label("Sync All Experiences to Calendar", systemImage: "arrow.clockwise")
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

    private func syncAllExperiences() {
        let fetchRequest = Experience.fetchRequest()
        let experiences = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
        for exp in experiences {
            calendarWrapper.createOrUpdateEvent(from: exp)
        }
        try? PersistenceController.shared.viewContext.save()
        toastViewModel.showSuccessToast(message: "Experiences Synced")
    }
}

struct CalendarSectionInSettings_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSectionInSettings()
    }
}
