import SwiftUI
import EventKit

struct CalendarSection: View {

    @AppStorage("calendarIdentifier") var calendarIdentifier: String = ""

    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @State private var isShowingActionSheet = false
    @State private var isShowingAlert = false

    var body: some View {
        Section(header: Text("Apple Calendar")) {
            if calendarWrapper.authorizationStatus == .notDetermined {
                Button("Allow Access to Apple Calendar") {
                    calendarWrapper.requestAccess()
                }
            } else if calendarWrapper.authorizationStatus == .authorized {
                if calendarWrapper.psychonautWikiCalendar != nil {
                    HStack {
                        Text("Your PsychonautWiki Calendar is All Set")
                        Spacer()
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundColor(.green)
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
