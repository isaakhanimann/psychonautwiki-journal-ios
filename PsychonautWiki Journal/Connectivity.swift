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
            if let text = userInfo["text"] as? String {
                self.receivedText = text
            } else {
                #if os(watchOS)
                if let number = userInfo["number"] as? String {
                    UserDefaults.standard.set(number, forKey: "complication_number")

                    let server = CLKComplicationServer.sharedInstance()
                    guard let complications = server.activeComplications else { return }

                    for complication in complications {
                        server.reloadTimeline(for: complication)
                    }
                }
                #endif
            }
        }
    }

    func sendMessage(_ data: [String: Any]) {
        let session = WCSession.default

        if session.isReachable {
            session.sendMessage(data) { response in
                DispatchQueue.main.async {
                    self.receivedText = "Received response: \(response)"
                }
            }
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.receivedText = text
                replyHandler(["response": "Be excellent to each other"])
            }
        }
    }
}
