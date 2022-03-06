import SwiftUI
import EventKit

class CalendarWrapper: ObservableObject {
    private let store = EKEventStore()
    @Published var authorizationStatus = EKAuthorizationStatus.notDetermined
    @Published var psychonautWikiCalendar: EKCalendar?

    var isSetupComplete: Bool {
        authorizationStatus == .authorized && psychonautWikiCalendar != nil
    }

    init() {
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authorizationStatus == .authorized {
            self.psychonautWikiCalendar = findPsychonautWikiCalendar()
        }
        self.authorizationStatus = authorizationStatus
    }

    func checkIfSomethingChanged() {
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authorizationStatus == .authorized {
            self.psychonautWikiCalendar = findPsychonautWikiCalendar()
        }
        self.authorizationStatus = authorizationStatus
    }

    func requestAccess() {
        store.requestAccess(to: .event) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    self.authorizationStatus = .authorized
                    self.psychonautWikiCalendar = self.findPsychonautWikiCalendar()
                }
            }
        }
    }

    func getSources() -> [EKSource] {
        store.sources
    }

    func createPsychonautWikiCalendar(with source: EKSource) throws {
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = "PsychonautWiki"
        calendar.cgColor = UIColor.blue.cgColor
        calendar.source = source
        try store.saveCalendar(calendar, commit: true)
        self.psychonautWikiCalendar = calendar
    }

    func createOrUpdateEvent(from experience: Experience) {
        guard let eventIdentifierUnwrapped = experience.eventIdentifier else {
            let eventIdentifier = createNewEvent(from: experience)
            experience.eventIdentifier = eventIdentifier
            return
        }

        guard store.event(withIdentifier: eventIdentifierUnwrapped) != nil else {
            let eventIdentifier = createNewEvent(from: experience)
            experience.eventIdentifier = eventIdentifier
            return
        }
        experience.lastSyncToCalendar = Date()
        updateEvent(with: experience)
    }

    private func createNewEvent(from experience: Experience) -> String? {
        guard isSetupComplete else {
            return nil
        }
        let event = EKEvent(eventStore: store)
        event.calendar = psychonautWikiCalendar
        event.alarms = []
        event.title = experience.titleUnwrapped
        event.notes = getNotes(from: experience)

        let (start, end) = getStartAndEnd(for: experience)
        event.startDate = start
        event.endDate = end
        do {
            try store.save(event, span: .thisEvent)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return event.eventIdentifier
    }

    private func updateEvent(with experience: Experience) {
        guard isSetupComplete else {
            return
        }
        guard let eventIdentifierUnwrapped = experience.eventIdentifier else {
            assertionFailure("Experience does not have an event yet")
            return
        }
        guard let eventUnwrapped = store.event(withIdentifier: eventIdentifierUnwrapped) else {
            assertionFailure("Failed to find event with identifier: \(eventIdentifierUnwrapped)")
            return
        }
        eventUnwrapped.title = experience.titleUnwrapped
        eventUnwrapped.notes = getNotes(from: experience)
        let (start, end) = getStartAndEnd(for: experience)
        eventUnwrapped.startDate = start
        eventUnwrapped.endDate = end
        do {
            try store.save(eventUnwrapped, span: .thisEvent)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    private func getStartAndEnd(for experience: Experience) -> (start: Date, end: Date) {
        if let start = experience.sortedIngestionsUnwrapped.first?.timeUnwrapped,
           let end = Experience.getEndTime(for: experience.sortedIngestionsUnwrapped) {
            return (start, end)
        } else {
            let fiveHours: TimeInterval = 5*60*60
            return (experience.creationDateUnwrapped, experience.creationDateUnwrapped.addingTimeInterval(fiveHours))
        }
    }

    private func getNotes(from experience: Experience) -> String {
        var result = ""
        if experience.sortedIngestionsUnwrapped.isEmpty {
            result  = "There are no ingestions\n"
        }
        for ingestion in experience.sortedIngestionsUnwrapped {
            result += "\(ingestion.timeUnwrappedAsString): "
            result += "\(ingestion.doseInfoString) of \(ingestion.substanceNameUnwrapped) "
            result += "\(ingestion.administrationRouteUnwrapped.displayString)\n"
        }
        result += "\n" + experience.textUnwrapped
        return result
    }

    private func findPsychonautWikiCalendar() -> EKCalendar? {
        store.calendars(for: .event).first(where: { calendar in
            calendar.title == "PsychonautWiki"
        })
    }
}
