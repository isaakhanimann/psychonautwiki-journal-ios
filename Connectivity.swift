import Foundation
import WatchConnectivity
import ClockKit

// swiftlint:disable type_body_length
class Connectivity: NSObject, ObservableObject, WCSessionDelegate {

    @Published var activationState = WCSessionActivationState.notActivated

    #if os(iOS)
    @Published var isWatchAppInstalled = false
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

    func updateComplication(with data: [String: Any]) {
        let session = WCSession.default

        if session.activationState == .activated && session.isComplicationEnabled {
            session.transferCurrentComplicationUserInfo(data)
            // swiftlint:disable line_length
            print("Attempted to send complication data. Remaining transfers: \(session.remainingComplicationUserInfoTransfers)")
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
            case .updateEnabledSubstances:
                self.receiveEnabledSubstances(userInfo: userInfo)
            case .updateFavoriteSubstances:
                self.receiveFavoriteSubstances(userInfo: userInfo)
            case .deleteAllIngestions:
                #if os(watchOS)
                self.receiveDeleteAll()
                #endif
            case .enableInteractions:
                self.receiveInteractions(userInfo: userInfo)
            }
        }
        //        DispatchQueue.main.async {
        //            if let text = userInfo["text"] as? String {
        //                self.receivedText = text
        //            } else {
        //                #if os(watchOS)
        //                if let number = userInfo["number"] as? String {
        //                    UserDefaults.standard.set(number, forKey: "complication_number")
        //
        //                    let server = CLKComplicationServer.sharedInstance()
        //                    guard let complications = server.activeComplications else { return }
        //
        //                    for complication in complications {
        //                        server.reloadTimeline(for: complication)
        //                    }
        //                }
        //                #endif
        //            }
        //        }
    }

    // MARK: Constants

    enum MessageType: String {
        case createIngestion
        case updateIngestion
        case deleteIngestion
        case updateEnabledSubstances
        case updateFavoriteSubstances
        case deleteAllIngestions
        case enableInteractions
    }

    private let messageTypeKey = "messageType"
    private let ingestionIdKey = "ingestionId"
    private let ingestionTimeKey = "createIngestionDate"
    private let ingestionSubstanceKey = "substanceName"
    private let ingestionRouteKey = "route"
    private let ingestionDoseKey = "dose"
    private let ingestionColorKey = "color"
    private let substanceNamesKey = "listOfSubstanceNames"
    private let interactionNamesKey = "listOfInteractionNames"

    private let substanceNameSeparator = "#"

    // MARK: Send Methods

    #if os(iOS)
    func sendIngestionDelete(for ingestionIdentifier: UUID?) {
        guard let identifierUnwrapped = ingestionIdentifier else {return}
        let data = [
            messageTypeKey: MessageType.deleteIngestion.rawValue,
            ingestionIdKey: identifierUnwrapped.uuidString
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendIngestionUpdate(for ingestion: Ingestion) {
        guard let identifier = ingestion.identifier else {return}
        guard let substanceName = ingestion.substanceCopy?.name else {return}
        let data = [
            messageTypeKey: MessageType.updateIngestion.rawValue,
            ingestionIdKey: identifier.uuidString,
            ingestionTimeKey: ingestion.timeUnwrapped,
            ingestionSubstanceKey: substanceName,
            ingestionRouteKey: ingestion.administrationRouteUnwrapped.rawValue,
            ingestionDoseKey: ingestion.dose,
            ingestionColorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendReplaceIngestions(ingestions: [Ingestion]) {
        sendDeleteAllIngestions()
        for ingestion in ingestions {
            sendNewIngestion(ingestion: ingestion)
        }
    }

    private func sendDeleteAllIngestions() {
        let data = [
            messageTypeKey: MessageType.deleteAllIngestions.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }
    #endif

    func sendNewIngestion(ingestion: Ingestion) {
        guard let identifier = ingestion.identifier else {return}
        guard let substanceName = ingestion.substanceCopy?.name else {return}
        let data = [
            messageTypeKey: MessageType.createIngestion.rawValue,
            ingestionIdKey: identifier.uuidString,
            ingestionTimeKey: ingestion.timeUnwrapped,
            ingestionSubstanceKey: substanceName,
            ingestionRouteKey: ingestion.administrationRouteUnwrapped.rawValue,
            ingestionDoseKey: ingestion.dose,
            ingestionColorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendEnabledSubstances(from file: SubstancesFile) {
        let namesOfEnabledSubstances = file.allEnabledSubstancesUnwrapped.map({$0.nameUnwrapped}).joined(separator: substanceNameSeparator)

        let data = [
            messageTypeKey: MessageType.updateEnabledSubstances.rawValue,
            substanceNamesKey: namesOfEnabledSubstances
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendFavoriteSubstances(from file: SubstancesFile) {
        let namesOfFavoriteSubstances = file.favoritesSorted.map({$0.nameUnwrapped}).joined(separator: substanceNameSeparator)

        let data = [
            messageTypeKey: MessageType.updateFavoriteSubstances.rawValue,
            substanceNamesKey: namesOfFavoriteSubstances
        ] as [String: Any]
        transferUserInfo(data)
    }

    func sendInteractions(from file: SubstancesFile) {
        let namesOfInteractions = file.generalInteractionsUnwrapped.filter({$0.isEnabled}).map({$0.nameUnwrapped}).joined(separator: substanceNameSeparator)

        let data = [
            messageTypeKey: MessageType.enableInteractions.rawValue,
            interactionNamesKey: namesOfInteractions
        ] as [String: Any]
        transferUserInfo(data)
    }

    // MARK: Receive Methods

    func receiveIngestionDelete(userInfo: [String: Any]) {
        guard let identifier = userInfo[ingestionIdKey] as? String else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        guard let experience = PersistenceController.shared.getLatestExperience() else {return}
        guard let ingestionToDelete = experience.sortedIngestionsUnwrapped.first(where: {$0.identifier == identifierUnwrapped}) else {return}

        PersistenceController.shared.delete(ingestion: ingestionToDelete)

        #if os(watchOS)
        ComplicationUpdater.updateActiveComplications()
        #endif
    }

    func receiveIngestionUpdate(userInfo: [String: Any]) {
        guard let identifier = userInfo[ingestionIdKey] as? String else {return}
        guard let createIngestionDate = userInfo[ingestionTimeKey] as? Date else {return}
        guard let route = userInfo[ingestionRouteKey] as? String else {return}
        guard let dose = userInfo[ingestionDoseKey] as? Double else {return}
        guard let colorName = userInfo[ingestionColorKey] as? String else {return}

        guard let routeUnwrapped = Roa.AdministrationRoute(rawValue: route) else {return}
        guard let colorUnwrapped = Ingestion.IngestionColor(rawValue: colorName) else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        guard let experience = PersistenceController.shared.getLatestExperience() else {return}
        guard let ingestionToUpdate = experience.sortedIngestionsUnwrapped.first(where: {$0.identifier == identifierUnwrapped}) else {return}

        PersistenceController.shared.updateIngestion(
            ingestionToUpdate: ingestionToUpdate,
            time: createIngestionDate,
            route: routeUnwrapped,
            color: colorUnwrapped,
            dose: dose
        )

        #if os(watchOS)
        ComplicationUpdater.updateActiveComplications()
        #endif
    }

    // swiftlint:disable cyclomatic_complexity
    func receiveNewIngestion(userInfo: [String: Any]) {
        guard let identifier = userInfo[ingestionIdKey] as? String else {return}
        guard let createIngestionDate = userInfo[ingestionTimeKey] as? Date else {return}
        guard let substanceName = userInfo[ingestionSubstanceKey] as? String else {return}
        guard let route = userInfo[ingestionRouteKey] as? String else {return}
        guard let dose = userInfo[ingestionDoseKey] as? Double else {return}
        guard let colorName = userInfo[ingestionColorKey] as? String else {return}

        #if os(iOS)
        var experienceToAddTo = PersistenceController.shared.getLatestExperience()
        if !(experienceToAddTo?.isActive ?? false) {
            guard let newExperience = PersistenceController.shared.createNewExperienceNow() else {return}
            experienceToAddTo = newExperience
        }
        #else
        let experienceToAddTo = PersistenceController.shared.getLatestExperience()
        #endif

        guard let foundSubstance = PersistenceController.shared.findSubstance(with: substanceName) else {return}
        guard let routeUnwrapped = Roa.AdministrationRoute(rawValue: route) else {return}
        guard foundSubstance.administrationRoutesUnwrapped.contains(routeUnwrapped) else {return}
        guard let colorUnwrapped = Ingestion.IngestionColor(rawValue: colorName) else {return}
        guard let experienceUnwrapped = experienceToAddTo else {return}
        guard let identifierUnwrapped = UUID(uuidString: identifier) else {return}

        PersistenceController.shared.createIngestion(
            identifier: identifierUnwrapped,
            addTo: experienceUnwrapped,
            substance: foundSubstance,
            ingestionTime: createIngestionDate,
            ingestionRoute: routeUnwrapped,
            color: colorUnwrapped,
            dose: dose
        )

        #if os(watchOS)
        ComplicationUpdater.updateActiveComplications()
        #endif
    }

    func receiveEnabledSubstances(userInfo: [String: Any]) {
        guard let namesOfEnabledSubstancesString = userInfo[substanceNamesKey] as? String else {return}
        let namesOfEnabledSubstances = namesOfEnabledSubstancesString.components(separatedBy: substanceNameSeparator)

        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            for name in namesOfEnabledSubstances {
                guard let foundSubstance = PersistenceController.shared.findSubstance(with: name) else {continue}
                foundSubstance.isEnabled = true
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }

    func receiveFavoriteSubstances(userInfo: [String: Any]) {
        guard let namesOfFavoriteSubstancesString = userInfo[substanceNamesKey] as? String else {return}
        let namesOfFavoriteSubstances = namesOfFavoriteSubstancesString.components(separatedBy: substanceNameSeparator)

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

    func receiveDeleteAll() {
        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            guard let currentExperience = PersistenceController.shared.getLatestExperience() else {return}
            for ingestion in currentExperience.sortedIngestionsUnwrapped {
                moc.delete(ingestion)
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
        #if os(watchOS)
        ComplicationUpdater.updateActiveComplications()
        #endif
    }

    func receiveInteractions(userInfo: [String: Any]) {
        guard let namesOfInteractionsString = userInfo[interactionNamesKey] as? String else {return}
        let namesOfInteractions = namesOfInteractionsString.components(separatedBy: substanceNameSeparator)

        let moc = PersistenceController.shared.container.viewContext
        moc.perform {
            for name in namesOfInteractions {
                guard let foundInteraction = PersistenceController.shared.findGeneralInteraction(with: name) else {continue}
                foundInteraction.isEnabled = true
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
        #if os(watchOS)
        ComplicationUpdater.updateActiveComplications()
        #endif
    }
}
