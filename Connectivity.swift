import Foundation
import WatchConnectivity
import ClockKit

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class Connectivity: NSObject, ObservableObject, WCSessionDelegate {

    @Published var activationState = WCSessionActivationState.notActivated

#if os(iOS)
    @Published var isWatchAppInstalled = false
    @Published var isComplicationEnabled = false
    @Published var isPaired = false
#endif

    // MARK: General Methods

    override init() {
        super.init()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

#if os(iOS)
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.activationState = activationState
            if activationState == .activated {
                self.isWatchAppInstalled = session.isWatchAppInstalled
                self.isComplicationEnabled = session.isComplicationEnabled
                self.isPaired = session.isPaired
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        DispatchQueue.main.async {
            self.activationState = session.activationState
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.activationState = session.activationState
        }
    }

#else
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.activationState = activationState
        }
    }
#endif

    func transferUserInfo(_ userInfo: [String: Any]) {
        let session = WCSession.default

        if session.activationState == .activated {
            session.transferUserInfo(userInfo)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        DispatchQueue.main.async {
            guard let messageType = userInfo[self.messageTypeKey] as? String else {return}
            guard let messageTypeUnwrapped = MessageType(rawValue: messageType) else {return}

            switch messageTypeUnwrapped {
            case .createIngestion:
                self.receiveNewIngestion(userInfo: userInfo)
            case .updateIngestion:
#if os(watchOS)
                self.receiveIngestionUpdate(userInfo: userInfo)
#endif
            case .deleteIngestion:
#if os(watchOS)
                self.receiveIngestionDelete(userInfo: userInfo)
#endif
            case .eyeState:
                self.receiveEyeState(userInfo: userInfo)
            case .updateFavoriteSubstances:
                self.receiveFavoriteSubstances(userInfo: userInfo)
            case .enableInteractions:
                self.receiveInteractions(userInfo: userInfo)
            case .syncMessageToWatch:
#if os(watchOS)
                self.receiveSyncMessage(userInfo: userInfo)
#endif
            }
        }
    }

    // MARK: Constants

    enum MessageType: String {
        case createIngestion
        case updateIngestion
        case deleteIngestion
        case eyeState
        case updateFavoriteSubstances
        case enableInteractions
        case syncMessageToWatch
    }

    private let messageTypeKey = "messageType"
    private let idKey = "ingestionId"
    private let timeKey = "ingestionTime"
    private let substanceNameKey = "substanceName"
    private let routeKey = "route"
    private let doseKey = "dose"
    private let colorKey = "color"
    private let eyeStateKey = "isEyeOpen"
    private let namesOfEnabledInteractionsKey = "namesOfEnabledInteractions"
    private let namesOfDisabledInteractionsKey = "namesOfDisabledInteractions"

    private let stringSeparator = "#"

    // MARK: Variables

    // This is needed such that the same ingestion is not added twice when 2 messages are queued
    private var createdIngestionUIDs = Set<UUID>()

    // MARK: Send Methods

#if os(iOS)

    func sendSyncMessageToWatch(with ingestions: [Ingestion]) {
        let ids = ingestions
            .map({$0.identifier?.uuidString ?? "Unknown"})
            .joined(separator: stringSeparator)
        let timesString = ingestions
            .map({String($0.timeUnwrapped.timeIntervalSince1970)})
            .joined(separator: stringSeparator)
        let namesOfSubstances = ingestions
            .map({$0.substanceCopy?.nameUnwrapped ?? "Unknown"})
            .joined(separator: stringSeparator)
        let administrationRoutes = ingestions
            .map({$0.administrationRouteUnwrapped.rawValue})
            .joined(separator: stringSeparator)
        let dosesString = ingestions
            .map({String($0.doseUnwrapped)})
            .joined(separator: stringSeparator)
        let colors = ingestions
            .map({$0.colorUnwrapped.rawValue})
            .joined(separator: stringSeparator)

        let data = [
            messageTypeKey: MessageType.syncMessageToWatch.rawValue,
            idKey: ids,
            timeKey: timesString,
            substanceNameKey: namesOfSubstances,
            routeKey: administrationRoutes,
            doseKey: dosesString,
            colorKey: colors
        ] as [String: Any]

        let session = WCSession.default
        if session.activationState == .activated {
            if session.isComplicationEnabled {
                session.transferCurrentComplicationUserInfo(data)
            } else {
                session.transferUserInfo(data)
            }
        }
    }

    func sendIngestionDelete(for ingestionIdentifier: UUID?) {
        guard let identifierUnwrapped = ingestionIdentifier else {return}
        let data = [
            messageTypeKey: MessageType.deleteIngestion.rawValue,
            idKey: identifierUnwrapped.uuidString
        ] as [String: Any]
        transferUserInfo(data)
    }

#endif

    func sendNewIngestion(ingestion: Ingestion) {
        guard let identifier = ingestion.identifier else {return}
        guard let substanceName = ingestion.substanceCopy?.name else {return}
        let data = [
            messageTypeKey: MessageType.createIngestion.rawValue,
            idKey: identifier.uuidString,
            timeKey: ingestion.timeUnwrapped,
            substanceNameKey: substanceName,
            routeKey: ingestion.administrationRouteUnwrapped.rawValue,
            doseKey: ingestion.dose,
            colorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendIngestionUpdate(for ingestion: Ingestion) {
        guard let identifier = ingestion.identifier else {return}
        guard let substanceName = ingestion.substanceCopy?.name else {return}
        let data = [
            messageTypeKey: MessageType.updateIngestion.rawValue,
            idKey: identifier.uuidString,
            timeKey: ingestion.timeUnwrapped,
            substanceNameKey: substanceName,
            routeKey: ingestion.administrationRouteUnwrapped.rawValue,
            doseKey: ingestion.dose,
            colorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendEyeState(isEyeOpen: Bool) {
        let data = [
            messageTypeKey: MessageType.eyeState.rawValue,
            eyeStateKey: isEyeOpen
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendFavoriteSubstances(from file: SubstancesFile) {
        let namesOfFavoriteSubstances = file.favoritesSorted.map({$0.nameUnwrapped}).joined(separator: stringSeparator)

        let data = [
            messageTypeKey: MessageType.updateFavoriteSubstances.rawValue,
            substanceNameKey: namesOfFavoriteSubstances
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendInteractions(from file: SubstancesFile) {
        let namesOfEnabled = file.generalInteractionsUnwrapped
            .filter({$0.isEnabled})
            .map({$0.nameUnwrapped})
            .joined(separator: stringSeparator)

        let namesOfDisabled = file.generalInteractionsUnwrapped
            .filter({!$0.isEnabled})
            .map({$0.nameUnwrapped})
            .joined(separator: stringSeparator)

        let data = [
            messageTypeKey: MessageType.enableInteractions.rawValue,
            namesOfEnabledInteractionsKey: namesOfEnabled,
            namesOfDisabledInteractionsKey: namesOfDisabled
        ] as [String: Any]
        transferUserInfo(data)
    }

    // MARK: Receive Methods

#if os(watchOS)

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func receiveSyncMessage(userInfo: [String: Any]) {
        guard let idsString = userInfo[idKey] as? String else {return}
        let idStrings = idsString.components(separatedBy: stringSeparator)

        guard let timesString = userInfo[timeKey] as? String else {return}
        let timeStrings = timesString.components(separatedBy: stringSeparator)

        guard let namesString = userInfo[substanceNameKey] as? String else {return}
        let names = namesString.components(separatedBy: stringSeparator)

        guard let administrationRoutesString = userInfo[routeKey] as? String else {return}
        let administrationRoutes = administrationRoutesString.components(separatedBy: stringSeparator)

        guard let dosesString = userInfo[doseKey] as? String else {return}
        let doseStrings = dosesString.components(separatedBy: stringSeparator)

        guard let colorsString = userInfo[colorKey] as? String else {return}
        let colors = colorsString.components(separatedBy: stringSeparator)

        let moc = PersistenceController.shared.container.viewContext
        moc.performAndWait {
            guard let experienceToUpdate = PersistenceController.shared.getLatestExperience() else {return}
            experienceToUpdate.sortedIngestionsUnwrapped.forEach { ingestion in
                createdIngestionUIDs.remove(ingestion.identifier ?? UUID())
                moc.delete(ingestion)
            }

            for index in 0..<idStrings.count {
                guard let identifier = UUID(uuidString: idStrings[safe: index] ?? "") else {continue}
                guard let timeInterval = TimeInterval(timeStrings[safe: index] ?? "") else {continue}
                let time = Date(timeIntervalSince1970: timeInterval)
                guard let route = Roa.AdministrationRoute(
                    rawValue: administrationRoutes[safe: index] ?? ""
                ) else {continue}
                guard let foundSubstance = PersistenceController.shared.findSubstance(
                    with: names[safe: index] ?? "Unknown"
                ) else {continue}
                guard let color = Ingestion.IngestionColor(rawValue: colors[safe: index] ?? "") else {continue}
                guard let dose = Double(doseStrings[safe: index] ?? "") else {continue}

                guard !createdIngestionUIDs.contains(identifier) else {continue}
                createdIngestionUIDs.insert(identifier)

                PersistenceController.shared.createIngestionWithoutSave(
                    context: moc,
                    identifier: identifier,
                    addTo: experienceToUpdate,
                    substance: foundSubstance,
                    ingestionTime: time,
                    ingestionRoute: route,
                    color: color,
                    dose: dose
                )
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }

        let server = CLKComplicationServer.sharedInstance()
        guard let complications = server.activeComplications else { return }

        for complication in complications {
            server.reloadTimeline(for: complication)
        }
    }
#endif

    func receiveIngestionDelete(userInfo: [String: Any]) {
        guard let identifier = userInfo[idKey] as? String else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        guard let experience = PersistenceController.shared.getLatestExperience() else {return}
        guard let ingestionToDelete = experience.sortedIngestionsUnwrapped
                .first(where: {$0.identifier == identifierUnwrapped}) else {return}

        PersistenceController.shared.delete(ingestion: ingestionToDelete)
#if os(watchOS)
        UserDefaults.standard.set(true, forKey: PersistenceController.needsToUpdateWatchFaceKey)
#endif
    }

    // swiftlint:disable cyclomatic_complexity
    func receiveNewIngestion(userInfo: [String: Any]) {
        guard let identifier = userInfo[idKey] as? String else {return}
        guard let createIngestionDate = userInfo[timeKey] as? Date else {return}
        guard let substanceName = userInfo[substanceNameKey] as? String else {return}
        guard let route = userInfo[routeKey] as? String else {return}
        guard let dose = userInfo[doseKey] as? Double else {return}
        guard let colorName = userInfo[colorKey] as? String else {return}

#if os(iOS)
        let experienceToAddTo = PersistenceController.shared.getOrCreateLatestExperience()
#else
        let experienceToAddTo = PersistenceController.shared.getLatestExperience()
#endif

        guard let foundSubstance = PersistenceController.shared.findSubstance(with: substanceName) else {return}
        guard let routeUnwrapped = Roa.AdministrationRoute(rawValue: route) else {return}
        guard foundSubstance.administrationRoutesUnwrapped.contains(routeUnwrapped) else {return}
        guard let colorUnwrapped = Ingestion.IngestionColor(rawValue: colorName) else {return}
        guard let experienceUnwrapped = experienceToAddTo else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        guard !createdIngestionUIDs.contains(identifierUnwrapped) else {return}
        createdIngestionUIDs.insert(identifierUnwrapped)

        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            PersistenceController.shared.createIngestionWithoutSave(
                context: moc,
                identifier: identifierUnwrapped,
                addTo: experienceUnwrapped,
                substance: foundSubstance,
                ingestionTime: createIngestionDate,
                ingestionRoute: routeUnwrapped,
                color: colorUnwrapped,
                dose: dose
            )
            try? moc.save()
        }
#if os(watchOS)
        UserDefaults.standard.set(true, forKey: PersistenceController.needsToUpdateWatchFaceKey)
#endif
    }

    func receiveIngestionUpdate(userInfo: [String: Any]) {
        guard let identifier = userInfo[idKey] as? String else {return}
        guard let createIngestionDate = userInfo[timeKey] as? Date else {return}
        guard let route = userInfo[routeKey] as? String else {return}
        guard let dose = userInfo[doseKey] as? Double else {return}
        guard let colorName = userInfo[colorKey] as? String else {return}

        guard let routeUnwrapped = Roa.AdministrationRoute(rawValue: route) else {return}
        guard let colorUnwrapped = Ingestion.IngestionColor(rawValue: colorName) else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        guard let experience = PersistenceController.shared.getLatestExperience() else {return}
        guard let ingestionToUpdate = experience.sortedIngestionsUnwrapped
                .first(where: {$0.identifier == identifierUnwrapped}) else {return}

        PersistenceController.shared.updateIngestion(
            ingestionToUpdate: ingestionToUpdate,
            time: createIngestionDate,
            route: routeUnwrapped,
            color: colorUnwrapped,
            dose: dose
        )

#if os(watchOS)
        UserDefaults.standard.set(true, forKey: PersistenceController.needsToUpdateWatchFaceKey)
#endif
    }

    func receiveEyeState(userInfo: [String: Any]) {
        guard let isEyeOpen = userInfo[eyeStateKey] as? Bool else {return}
        guard let file = PersistenceController.shared.getCurrentFile() else {return}

        PersistenceController.shared.toggleEye(to: isEyeOpen, modifyFile: file)
        UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey)

    }

    func receiveFavoriteSubstances(userInfo: [String: Any]) {
        guard let namesOfFavoriteSubstancesString = userInfo[substanceNameKey] as? String else {return}
        let namesOfFavoriteSubstances = namesOfFavoriteSubstancesString.components(separatedBy: stringSeparator)

        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            for name in namesOfFavoriteSubstances {
                guard let foundSubstance = PersistenceController.shared.findSubstance(with: name) else {continue}
                foundSubstance.isFavorite = true
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }

    func receiveInteractions(userInfo: [String: Any]) {
        guard let enabledString = userInfo[namesOfEnabledInteractionsKey] as? String else {return}
        let namesOfEnabled = enabledString.components(separatedBy: stringSeparator)

        guard let disabledString = userInfo[namesOfDisabledInteractionsKey] as? String else {return}
        let namesOfDisabled = disabledString.components(separatedBy: stringSeparator)

        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            for name in namesOfEnabled {
                guard let foundInteraction = PersistenceController.shared.findGeneralInteraction(
                    with: name
                ) else {continue}
                foundInteraction.isEnabled = true
            }
            for name in namesOfDisabled {
                guard let foundInteraction = PersistenceController.shared.findGeneralInteraction(
                    with: name
                ) else {continue}
                foundInteraction.isEnabled = false
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}
