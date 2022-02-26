import Foundation
import WatchConnectivity
import ClockKit

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
            self.receiveEyeState(userInfo: userInfo)
        }
    }

    private let eyeStateKey = "isEyeOpen"

    func sendEyeState(isEyeOpen: Bool) {
        let data = [
            eyeStateKey: isEyeOpen
        ] as [String: Any]
        transferUserInfo(data)
    }

    func receiveEyeState(userInfo: [String: Any]) {
        guard let isEyeOpen = userInfo[eyeStateKey] as? Bool else {return}
        UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey)
    }
}
