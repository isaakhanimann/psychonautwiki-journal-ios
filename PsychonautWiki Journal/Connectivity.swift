import Foundation
import WatchConnectivity
import ClockKit

class Connectivity: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedText = ""

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
            if activationState == .activated {
                if session.isWatchAppInstalled {
                    self.receivedText = "Watch app is installed!"
                }
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func updateComplication(with data: [String: Any]) {
        let session = WCSession.default

        if session.activationState == .activated && session.isComplicationEnabled {
            session.transferCurrentComplicationUserInfo(data)
            // swiftlint:disable line_length
            receivedText = "Attempted to send complication data. Remaining transfers: \(session.remainingComplicationUserInfoTransfers)"
        }
    }
    #else
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
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
            if let isUpdate = userInfo[self.isUpdateKey] as? Bool, isUpdate {
                #if os(watchOS)
                self.receiveIngestionUpdate(userInfo: userInfo)
                #endif
            } else {
                self.receiveNewIngestion(userInfo: userInfo)
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

    func sendIngestionUpdate(for ingestion: Ingestion) {
        let data = [
            isUpdateKey: true,
            ingestionIdKey: ingestion.identifier?.uuidString ?? "Unknown",
            ingestionTimeKey: ingestion.timeUnwrapped,
            ingestionSubstanceKey: ingestion.substanceCopy?.name ?? "Unknown",
            ingestionRouteKey: ingestion.administrationRouteUnwrapped.rawValue,
            ingestionDoseKey: ingestion.dose,
            ingestionColorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
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
    }

    //        func receiveIngestionUpdate(userInfo: [String: Any]) {
    //            guard let identifier = userInfo[ingestionIdKey] as? UUID else {return}
    //            guard let createIngestionDate = userInfo[ingestionTimeKey] as? Date else {return}
//            guard let route = userInfo[ingestionRouteKey] as? Roa.AdministrationRoute else {return}
//            guard let dose = userInfo[ingestionDoseKey] as? Double else {return}
//            guard let color = userInfo[ingestionColorKey] as? Ingestion.IngestionColor else {return}
//
//            guard let experience = PersistenceController.shared.getLatestExperience() else {return}
//            guard let ingestionToUpdate = experience.sortedIngestionsUnwrapped.first(where: {$0.identifier == identifier}) else {return}
//
//            PersistenceController.shared.updateIngestion(
//                ingestionToUpdate: ingestionToUpdate,
//                time: createIngestionDate,
//                route: route,
//                color: color,
//                dose: dose
//            )
//        }

    func sendNewIngestion(ingestion: Ingestion) {
        let data = [
            isUpdateKey: false,
            ingestionIdKey: ingestion.identifier?.uuidString ?? "Unknown",
            ingestionTimeKey: ingestion.timeUnwrapped,
            ingestionSubstanceKey: ingestion.substanceCopy?.name ?? "Unknown",
            ingestionRouteKey: ingestion.administrationRouteUnwrapped.rawValue,
            ingestionDoseKey: ingestion.dose,
            ingestionColorKey: ingestion.colorUnwrapped.rawValue
        ] as [String: Any]
        transferUserInfo(data)
    }

    private let isUpdateKey = "isUpdate"
    private let ingestionIdKey = "ingestionId"
    private let ingestionTimeKey = "createIngestionDate"
    private let ingestionSubstanceKey = "substanceName"
    private let ingestionRouteKey = "route"
    private let ingestionDoseKey = "dose"
    private let ingestionColorKey = "color"

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
    }

}
